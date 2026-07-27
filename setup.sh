#!/bin/bash

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Updating Homebrew..."
brew update
brew upgrade

echo "Installing packages from Brewfile..."
brew bundle --file="$DOTFILES/Brewfile"

echo "Creating symlinks..."
stow --target="$HOME" --restow .

if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing oh-my-zsh plugins..."

    if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions \
            "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
    fi

    if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting" ]; then
        git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git \
            "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting"
    fi
else
    echo "oh-my-zsh not found, skipping plugin installation"
fi

echo "Initializing git submodules..."
git -C "$DOTFILES" submodule update --init --recursive

echo "Setting up opencode plugins and skills..."
mkdir -p "$HOME/.config/opencode/plugins"
ln -sf "$HOME/.config/opencode/superpowers/.opencode/plugins/superpowers.js" \
       "$HOME/.config/opencode/plugins/superpowers.js"
mkdir -p "$HOME/.config/opencode/skills"
ln -sf "$HOME/.config/opencode/superpowers/skills" \
       "$HOME/.config/opencode/skills/superpowers"

# Agent config dirs (~/.claude, ~/.codex, ~/.agents) and ~/.ssh hold live state and
# credentials next to their config, so stow must never fold them. Link file by file.
link_config() {
    local src="$DOTFILES/$1" dst="$HOME/$2"
    if [ ! -e "$src" ]; then
        echo "  skip $2 (not in repo)"
        return
    fi
    mkdir -p "$(dirname "$dst")"
    ln -sfn "$src" "$dst"
    echo "  linked $2"
}

echo "Linking agent and ssh configs..."
link_config .claude/settings.json                   .claude/settings.json
link_config .claude/plugins/installed_plugins.json  .claude/plugins/installed_plugins.json
link_config .claude/plugins/known_marketplaces.json .claude/plugins/known_marketplaces.json
link_config .agents/.skill-lock.json                .agents/.skill-lock.json
link_config .codex/config.toml                      .codex/config.toml
link_config .codex/keybindings.json                 .codex/keybindings.json
link_config .codex/rules/default.rules              .codex/rules/default.rules
link_config .ssh/config                             .ssh/config

echo "Building bat theme cache..."
bat cache --build

if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Applying macOS defaults..."
    bash "$DOTFILES/macos-defaults.sh"
fi

cat <<'EOF'

Installation complete.

Remaining manual steps:
  1. Sign in to 1Password CLI:  op signin
  2. Create ~/.zshenv.local for machine-local secrets (never committed):
       echo 'export SOME_TOKEN="$(op read op://Private/some-item/credential)"' > ~/.zshenv.local
  3. Reinstall agent skills from the lock file if they are missing.
EOF
