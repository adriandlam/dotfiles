#!/bin/sh
# Claude Code status line, styled to match the Pure zsh prompt configured in ~/.zshrc.
# Palette is mirrored from the `zstyle :prompt:pure:*` lines there — keep them in sync:
#   path #8c97ff   branch #c2a1ff   dirty #f5c56a   symbol #8c97ff

PATH_COLOR='\033[38;2;140;151;255m'   # #8c97ff  zstyle :prompt:pure:path
BRANCH_COLOR='\033[38;2;194;161;255m' # #c2a1ff  zstyle :prompt:pure:git:branch
DIRTY_COLOR='\033[38;2;245;197;106m'  # #f5c56a  zstyle :prompt:pure:git:dirty
SYMBOL_COLOR='\033[38;2;140;151;255m' # #8c97ff  zstyle :prompt:pure:prompt:success
MUTED='\033[38;2;99;107;123m'
RESET='\033[0m'

input=$(cat)

{
  read -r cwd
  read -r name
  read -r rem
} <<EOF
$(printf '%s' "$input" | jq -r '
  (.workspace.current_dir // .cwd // ""),
  (.session_name // ""),
  (.context_window.remaining_percentage // "" | tostring)')
EOF

# Pure prints the whole path with $HOME collapsed to ~, not just the basename.
case "$cwd" in
  "$HOME") dir='~' ;;
  "$HOME"/*) dir="~${cwd#"$HOME"}" ;;
  *) dir="$cwd" ;;
esac

# --no-optional-locks on every call is load-bearing, not tidiness. This runs on
# every UI refresh, and `git status` writes a refreshed stat cache back to
# .git/index whenever a tracked file's mtime moved — taking .git/index.lock to do
# it. Against a session actively editing this repo, the status line wins that race
# often enough that `git add`/`git commit` fail with "index.lock: File exists".
# The flag makes git skip the write instead (same as GIT_OPTIONAL_LOCKS=0).
git='git --no-optional-locks'

branch=$($git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null) ||
  branch=$($git -C "$cwd" rev-parse --short HEAD 2>/dev/null)

# head -c1 lets git exit early once any change is seen, so this stays cheap in large repos.
dirty=''
[ -n "$branch" ] && [ -n "$($git -C "$cwd" status --porcelain 2>/dev/null | head -c1)" ] && dirty='*'

out=''
[ -n "$name" ] && out="${MUTED}${name}${RESET} "
out="${out}${PATH_COLOR}${dir}${RESET}"
[ -n "$branch" ] && out="${out} ${BRANCH_COLOR}${branch}${RESET}${DIRTY_COLOR}${dirty}${RESET}"
[ -n "$rem" ] && out="${out} ${MUTED}${rem}%${RESET}"

printf "%b\n" "${out} ${SYMBOL_COLOR}>${RESET}"
