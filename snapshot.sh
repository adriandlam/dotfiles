#!/bin/bash
#
# Refresh the config files this repo can only snapshot, not symlink.
#
# Most config is symlinked, so edits land in the repo automatically. These files
# are the exception: the apps that own them write by atomic replace, which
# deletes a symlink the first time the file changes. Run this after changing
# your Claude plugin set, or before committing, to pull the live copies back in.

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

snapshot() {
    local src="$HOME/$1" dst="$DOTFILES/$2"
    if [ ! -e "$src" ]; then
        echo "  skip $1 (not on this machine)"
        return
    fi
    mkdir -p "$(dirname "$dst")"
    if cmp -s "$src" "$dst" 2>/dev/null; then
        echo "  unchanged $1"
    else
        cp "$src" "$dst"
        echo "  updated $1"
    fi
}

echo "Snapshotting replace-on-write config..."
snapshot .claude/plugins/installed_plugins.json  .claude/plugins/installed_plugins.json
snapshot .claude/plugins/known_marketplaces.json .claude/plugins/known_marketplaces.json

echo "Refreshing Brewfile..."
brew bundle dump --force --describe --file="$DOTFILES/Brewfile"
echo "  Brewfile rewritten"

echo
echo "Done. Review with: git -C \"$DOTFILES\" diff"
