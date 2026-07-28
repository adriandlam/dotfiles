#!/bin/sh
# PreToolUse (Bash) — never let a git command skip its own hooks.
#
# `--no-verify` disables the pre-commit/commit-msg/pre-push hooks, which is the one
# class of flag whose entire purpose is to bypass a check someone deliberately
# installed. A permission deny rule can't cover it: the flag appears at any argument
# position (`git commit -m x --no-verify`), so patterns like
# `Bash(git commit --no-verify*)` miss most real invocations.
#
# Matching the raw command string is too broad in the other direction — that also
# fires on commands which merely *mention* the flag, like grepping for it or echoing
# documentation about it. So split the command into segments on shell separators and
# only inspect segments that actually *invoke* git: first word `git` once leading
# VAR=value assignments and process wrappers are stripped. A
# `printf '...--no-verify...'` segment starts with printf and is correctly ignored.
#
# Deliberately no sed: BSD sed rejects `;` after a label, so the loop-and-branch form
# this needs is not portable between macOS and Linux. Parameter expansion is.
#
# Returning permissionDecision "deny" on exit 0 gives a readable reason rather than a
# bare hook failure. The user can still run it themselves with `!`.

set -u
set -f # no globbing when word-splitting a segment into tokens

input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty')
[ -n "$cmd" ] || exit 0

TAB=$(printf '\t')

deny() {
  cat <<'JSON'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "This skips the git hooks this repo installed on purpose. Fix what the hook reports rather than bypassing it. If skipping is genuinely correct here, run the command yourself with ! so the decision is yours."
  }
}
JSON
  exit 0
}

# Reduce a segment to the command it actually runs: drop leading whitespace, then any
# `VAR=value` assignments and process wrappers, so `LANG=C git commit ...` and
# `timeout 5 git push ...` still resolve to a git invocation.
unwrap() {
  s=$1
  while :; do
    case $s in
      " "*|"$TAB"*) s=${s#?}; continue ;;
    esac
    tok=${s%% *}
    [ -n "$tok" ] || break
    case $tok in
      [A-Za-z_]*=*) s=${s#"$tok"}; s=${s# }; continue ;;
      env|nohup|nice|command) s=${s#"$tok"}; s=${s# }; continue ;;
      timeout)
        s=${s#"$tok"}; s=${s# }        # drop `timeout`
        s=${s#"${s%% *}"}; s=${s# }    # drop its duration argument
        continue ;;
    esac
    break
  done
  printf '%s' "$s"
}

# Each separator character becomes a newline, so one segment is one candidate
# invocation. `&&` and `||` turn into two splits, which is harmless.
printf '%s\n' "$cmd" | tr ';|&' '\n\n\n' | while IFS= read -r raw; do
  seg=$(unwrap "$raw")

  case $seg in
    git|"git "*|*/git|*/git" "*) ;;
    *) continue ;;
  esac

  case " $seg " in
    *" --no-verify "*) echo DENY; continue ;;
  esac

  # `-n` is --no-verify for these subcommands, and git accepts bundled short flags, so
  # `git commit -nm msg` skips hooks too. Of git commit's single-dash flags only `-n`
  # contains the letter n, so "single-dash token containing n" is precise here.
  # Not applied to `git push`, where -n means --dry-run and is harmless.
  case $seg in
    *"git commit "*|*"git merge "*)
      for tok in $seg; do
        case $tok in
          --*) ;;
          -*n*) echo DENY; break ;;
        esac
      done ;;
  esac
done | grep -q DENY && deny

exit 0
