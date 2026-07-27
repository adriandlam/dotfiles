#!/bin/bash

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v brew >/dev/null 2>&1; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    for p in /opt/homebrew/bin/brew /usr/local/bin/brew; do
        [ -x "$p" ] && eval "$("$p" shellenv)" && break
    done
fi

echo "Updating Homebrew..."
brew update
brew upgrade

echo "Installing packages from Brewfile..."
brew bundle --file="$DOTFILES/Brewfile"

# Stow "folds" a directory — replaces it with one symlink into this repo — whenever
# the target does not already exist. That is fine for directories we own entirely
# (ghostty, nvim, bat), but catastrophic for ones where an app also writes secrets
# or state: a folded ~/.config would put gh's hosts.yml, ngrok and rclone configs
# inside a public git repo. Creating them first forces stow to link file-by-file.
echo "Pre-creating directories stow must not fold..."
for d in .config .config/atuin .config/gh .config/mole .config/zed .pi .pi/agent; do
    mkdir -p "$HOME/$d"
done

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

# Claude Code rewrites the plugin manifests by atomic replace, which destroys a
# symlink on the first plugin change. Seed those on a fresh machine instead, and
# refresh the repo copy with ./snapshot.sh when the plugin set changes.
seed_config() {
    local src="$DOTFILES/$1" dst="$HOME/$2"
    if [ ! -e "$src" ]; then
        echo "  skip $2 (not in repo)"
    elif [ -e "$dst" ]; then
        echo "  kept $2 (already present)"
    else
        mkdir -p "$(dirname "$dst")"
        cp "$src" "$dst"
        echo "  seeded $2"
    fi
}

echo "Linking agent and ssh configs..."
link_config .claude/settings.json                   .claude/settings.json
seed_config .claude/plugins/installed_plugins.json  .claude/plugins/installed_plugins.json
seed_config .claude/plugins/known_marketplaces.json .claude/plugins/known_marketplaces.json
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
