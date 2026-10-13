# Stamp the start of init so the startup banner can report what it cost. This
# lives at the top of .zshenv rather than in .zshrc so the number covers every
# file zsh sources, not just the last one. zsh/datetime is a builtin module and
# EPOCHREALTIME is a float, so this is free and has microsecond resolution.
# Interactive shells only: scripts never print a banner, so they never pay.
if [[ -o interactive ]]; then
  zmodload zsh/datetime
  typeset -gF _DOTFILES_INIT_START=$EPOCHREALTIME
fi

# Drop duplicate PATH entries, keeping the first. Nested shells re-run every
# `export PATH=...:$PATH` line, so without this each level adds another copy.
typeset -U path PATH

[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# lazygit reads ~/Library/Application Support on macOS, not ~/.config
export LG_CONFIG_FILE="$HOME/.config/lazygit/config.yml"

# Machine-local secrets and overrides. Never committed — see .gitignore.
# Populate with 1Password:
#   export SOME_TOKEN="$(op read op://Private/some-item/credential)"
[ -f "$HOME/.zshenv.local" ] && . "$HOME/.zshenv.local"
