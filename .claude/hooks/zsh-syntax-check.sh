#!/bin/sh
# PostToolUse (Edit|Write) — refuse to leave a zsh startup file unparseable.
#
# A syntax error in ~/.zshrc is not an ordinary bug: it breaks the login shell you
# would use to fix it, and you find out at the next new terminal rather than now.
# `zsh -n` parses without executing, so this is safe to run on a file that sources
# secrets or starts a daemon.
#
# Exit 2 is the blocking convention: stdout is ignored and stderr is fed back as
# the error, so Claude sees the actual parser message and can correct it.

set -u

input=$(cat)
file=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')

[ -n "$file" ] || exit 0
[ -f "$file" ] || exit 0

# .zshenv* rather than .zshenv catches .zshenv.local, the machine-local secrets file.
case "$file" in
  *.zsh|*/.zshrc|*/.zshenv*|*/.zprofile|*/.zlogin|*/.zlogout) ;;
  *) exit 0 ;;
esac

if err=$(zsh -n "$file" 2>&1); then
  exit 0
fi

printf 'zsh could not parse %s — this file is sourced by every new shell:\n\n%s\n' \
  "$file" "$err" >&2
exit 2
