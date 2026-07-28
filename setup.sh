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

# Homebrew leaves the prefix's share/ group-writable whenever it creates new
# subdirectories there, so that several admin accounts can share one install.
# compaudit refuses that above any fpath entry, and compinit then prompts and
# aborts — which is exactly what a Brewfile addition triggered on 2026-07-27.
chmod g-w "$(brew --prefix)/share" 2>/dev/null || true

# Stow "folds" a directory — replaces it with one symlink into this repo — whenever
# the target does not already exist. That is fine for directories we own entirely
# (ghostty, nvim, bat), but catastrophic for ones where an app also writes secrets
# or state: a folded ~/.config would put gh's hosts.yml, ngrok and rclone configs
# inside a public git repo. Creating them first forces stow to link file-by-file.
echo "Pre-creating directories stow must not fold..."
for d in .config .config/atuin .config/gh .config/mole .config/zed; do
    mkdir -p "$HOME/$d"
done

echo "Creating symlinks..."
stow --target="$HOME" --restow .

# .zshrc sources $ZSH/oh-my-zsh.sh unconditionally, so a missing install is a
# broken shell rather than a degraded one. Install it rather than skipping.
#
# KEEP_ZSHRC matters: the installer rewrites ~/.zshrc by default, which here is
# a stow symlink into this repo. Without it, a fresh install would clobber it.
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing oh-my-zsh..."
    RUNZSH=no KEEP_ZSHRC=yes sh -c \
        "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# No plugin clones here on purpose. zsh-autosuggestions, fast-syntax-highlighting
# and zsh-autocomplete all come from the Brewfile, and .zshrc sources them from
# $HOMEBREW_PREFIX directly — one source, and `brew upgrade` keeps them current.

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
link_config .claude/statusline.sh                   .claude/statusline.sh
link_config .claude/hooks/block-no-verify.sh        .claude/hooks/block-no-verify.sh
link_config .claude/hooks/zsh-syntax-check.sh       .claude/hooks/zsh-syntax-check.sh
seed_config .claude/plugins/installed_plugins.json  .claude/plugins/installed_plugins.json
seed_config .claude/plugins/known_marketplaces.json .claude/plugins/known_marketplaces.json
link_config .agents/.skill-lock.json                .agents/.skill-lock.json
link_config .codex/config.toml                      .codex/config.toml
link_config .codex/keybindings.json                 .codex/keybindings.json
link_config .codex/rules/default.rules              .codex/rules/default.rules
link_config .ssh/config                             .ssh/config

echo "Building bat theme cache..."
bat cache --build

# Repo-local, never --global: core.hooksPath applies to whichever repo it is set
# in, and a global value would point every clone on this machine at these hooks.
echo "Wiring the pre-commit secret scan..."
git -C "$DOTFILES" config core.hooksPath .githooks
chmod +x "$DOTFILES/.githooks/"* 2>/dev/null || true

if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Applying macOS defaults..."
    bash "$DOTFILES/macos-defaults.sh"
fi

cat <<'EOF'

Installation complete.

Verify the install with ./doctor.sh

Remaining manual steps:
  1. Sign in to 1Password CLI:  op signin
  2. Create ~/.zshenv.local for machine-local secrets (never committed):
       echo 'export SOME_TOKEN="$(op read op://Private/some-item/credential)"' > ~/.zshenv.local
  3. Reinstall agent skills from the lock file if they are missing.
EOF
