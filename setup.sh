#!/bin/bash
#
# Install this dotfiles repo onto a machine.
#
# Reports in the same vocabulary as doctor.sh: a bold header per section, one
# indented line per thing done. The helpers are duplicated rather than sourced
# so this script stays standalone on a machine with nothing set up yet.
#
# Commands that install things (brew, stow, curl) keep their own raw output —
# it is not piped through an indenter, because sudo password prompts from cask
# installs would be swallowed by the buffering.

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ok()    { printf '  \033[32m✓\033[0m %s\n' "$1"; }
skip()  { printf '  \033[33m!\033[0m %s\n' "$1"; }
info()  { printf '  \033[2m·\033[0m %s\n' "$1"; }
head_() { printf '\n\033[1m%s\033[0m\n' "$1"; }

# ── Homebrew ──────────────────────────────────────────────────────────────
head_ "Homebrew"

if ! command -v brew >/dev/null 2>&1; then
    info "installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    for p in /opt/homebrew/bin/brew /usr/local/bin/brew; do
        [ -x "$p" ] && eval "$("$p" shellenv)" && break
    done
    ok "Homebrew installed"
else
    ok "Homebrew already installed"
fi

info "updating and upgrading formulae"
brew update
brew upgrade
ok "Homebrew up to date"

# ── Packages ──────────────────────────────────────────────────────────────
head_ "Packages"

info "installing from the Brewfile"
brew bundle --file="$DOTFILES/Brewfile"
ok "Brewfile installed"

# Homebrew leaves the prefix's share/ group-writable whenever it creates new
# subdirectories there, so that several admin accounts can share one install.
# compaudit refuses that above any fpath entry, and compinit then prompts and
# aborts — which is exactly what a Brewfile addition triggered on 2026-07-27.
chmod g-w "$(brew --prefix)/share" 2>/dev/null || true
ok "group-write cleared from $(brew --prefix)/share, so compinit stays quiet"

# ── Symlinks ──────────────────────────────────────────────────────────────
head_ "Symlinks"

# Stow "folds" a directory — replaces it with one symlink into this repo — whenever
# the target does not already exist. That is fine for directories we own entirely
# (ghostty, nvim, bat), but catastrophic for ones where an app also writes secrets
# or state: a folded ~/.config would put gh's hosts.yml, ngrok and rclone configs
# inside a public git repo. Creating them first forces stow to link file-by-file.
for d in .config .config/atuin .config/gh .config/mole .config/zed; do
    mkdir -p "$HOME/$d"
done
ok "pre-created the directories stow must not fold"

stow --target="$HOME" --restow .
ok "stow-managed files linked into \$HOME"

# ── Shell ─────────────────────────────────────────────────────────────────
head_ "Shell"

# .zshrc sources $ZSH/oh-my-zsh.sh unconditionally, so a missing install is a
# broken shell rather than a degraded one. Install it rather than skipping.
#
# KEEP_ZSHRC matters: the installer rewrites ~/.zshrc by default, which here is
# a stow symlink into this repo. Without it, a fresh install would clobber it.
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    info "installing oh-my-zsh"
    RUNZSH=no KEEP_ZSHRC=yes sh -c \
        "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    ok "oh-my-zsh installed"
else
    ok "oh-my-zsh already installed"
fi

# No plugin clones here on purpose. zsh-autosuggestions, fast-syntax-highlighting
# and zsh-autocomplete all come from the Brewfile, and .zshrc sources them from
# $HOMEBREW_PREFIX directly — one source, and `brew upgrade` keeps them current.
info "zsh plugins come from the Brewfile, not from clones here"

# ── Agent & ssh configs ───────────────────────────────────────────────────
# Agent config dirs (~/.claude, ~/.codex, ~/.agents) and ~/.ssh hold live state and
# credentials next to their config, so stow must never fold them. Link file by file.
head_ "Agent & ssh configs"

link_config() {
    local src="$DOTFILES/$1" dst="$HOME/$2"
    if [ ! -e "$src" ]; then
        skip "$2 not in the repo"
        return
    fi
    mkdir -p "$(dirname "$dst")"
    ln -sfn "$src" "$dst"
    ok "linked $2"
}

# Claude Code rewrites the plugin manifests by atomic replace, which destroys a
# symlink on the first plugin change. Seed those on a fresh machine instead, and
# refresh the repo copy with ./snapshot.sh when the plugin set changes.
seed_config() {
    local src="$DOTFILES/$1" dst="$HOME/$2"
    if [ ! -e "$src" ]; then
        skip "$2 not in the repo"
    elif [ -e "$dst" ]; then
        info "kept $2 (already present)"
    else
        mkdir -p "$(dirname "$dst")"
        cp "$src" "$dst"
        ok "seeded $2"
    fi
}

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

# ── Tooling ───────────────────────────────────────────────────────────────
head_ "Tooling"

bat cache --build >/dev/null
ok "bat theme cache built"

# Repo-local, never --global: core.hooksPath applies to whichever repo it is set
# in, and a global value would point every clone on this machine at these hooks.
git -C "$DOTFILES" config core.hooksPath .githooks
chmod +x "$DOTFILES/.githooks/"* 2>/dev/null || true
ok "pre-commit secret scan wired (core.hooksPath=.githooks)"

# ── macOS defaults ────────────────────────────────────────────────────────
if [[ "$OSTYPE" == "darwin"* ]]; then
    bash "$DOTFILES/macos-defaults.sh"
else
    head_ "macOS defaults"
    skip "not macOS — skipped"
fi

# ── Next steps ────────────────────────────────────────────────────────────
head_ "Next steps"

info "verify the install with ./doctor.sh"
info "sign in to the 1Password CLI:  op signin"
info "create ~/.zshenv.local for machine-local secrets (never committed):"
printf '      echo '\''export SOME_TOKEN="$(op read op://Private/some-item/credential)"'\'' > ~/.zshenv.local\n'
info "reinstall agent skills from the lock file if they are missing"

printf '\n\033[1mInstallation complete.\033[0m\n'
