# Stamp the start of init so the startup banner can report what it cost. This
# lives at the top of .zshenv rather than in .zshrc so the number covers every
# file zsh sources, not just the last one. zsh/datetime is a builtin module and
# EPOCHREALTIME is a float, so this is free and has microsecond resolution.
# Interactive shells only: scripts never print a banner, so they never pay.
if [[ -o interactive ]]; then
  zmodload zsh/datetime
  typeset -gF _DOTFILES_INIT_START=$EPOCHREALTIME
fi

. "$HOME/.cargo/env"

# Machine-local secrets and overrides. Never committed — see .gitignore.
# Populate with 1Password:
#   export SOME_TOKEN="$(op read op://Private/some-item/credential)"
[ -f "$HOME/.zshenv.local" ] && . "$HOME/.zshenv.local"
