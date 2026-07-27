. "$HOME/.cargo/env"

# Machine-local secrets and overrides. Never committed — see .gitignore.
# Populate with 1Password:
#   export SOME_TOKEN="$(op read op://Private/some-item/credential)"
[ -f "$HOME/.zshenv.local" ] && . "$HOME/.zshenv.local"
