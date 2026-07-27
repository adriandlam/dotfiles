# dotfiles

macOS config, managed with [GNU Stow](https://www.gnu.org/software/stow/).

```bash
cd ~
git clone git@github.com:adriandlam/dotfiles
cd dotfiles
./setup.sh
```

## What's here

| Path | Contents |
|---|---|
| `.zshrc`, `.zshenv` | Shell config. Secrets live in `~/.zshenv.local`, which is never committed. |
| `.gitconfig`, `.config/git` | Git config and delta theme |
| `.config/nvim` | LazyVim setup |
| `.config/ghostty`, `.config/bat`, `.config/eza`, `.config/lazygit`, `.config/atuin` | Terminal and CLI tooling |
| `.aerospace.toml` | Window manager |
| `.claude`, `.codex`, `.agents` | AI agent config (settings and manifests only — no state, no credentials) |
| `.config/opencode` | opencode config, with superpowers as a submodule |
| `.config/zed` | Zed settings and keymap |
| `Brewfile` | Every package, cask, tap and global npm/cargo/go install |
| `macos-defaults.sh` | `defaults write` settings |
| `vscode/extensions.txt` | Extension list (install with the one-liner below) |

## How linking works

`stow --target="$HOME" .` mirrors this tree into `~`. Anything stow must *not* fold is
listed in `.stow-local-ignore` and linked file-by-file at the end of `setup.sh` instead.

That distinction matters: `~/.claude`, `~/.codex`, `~/.agents` and `~/.ssh` all hold live
state and credentials next to their config. Symlinking those directories wholesale would
pull session logs, caches and auth tokens into a public repo. Only individual config files
are linked.

For the same reason `.config/raycast/extensions/` and `vscode/extensions/` are gitignored:
they are recompiled bundles and downloaded binaries, not config.

### Snapshots

A few files can't be symlinked at all. Claude Code rewrites its plugin manifests by
atomic replace, which deletes a symlink the first time the plugin set changes. Those are
copied on a fresh install and refreshed on demand:

```bash
./snapshot.sh    # pull live plugin manifests, Brewfile and extension list into the repo
```

Everything else is symlinked, so edits land in the repo automatically.

## Packages

```bash
brew bundle --file=Brewfile          # install everything
brew bundle dump --force --describe  # rewrite Brewfile from current state
brew bundle cleanup --force          # uninstall anything not in the Brewfile
```

## VS Code extensions

```bash
xargs -n1 code --install-extension < vscode/extensions.txt   # restore
code --list-extensions > vscode/extensions.txt               # update
```

## Secrets

Nothing secret is committed. Machine-local environment variables go in `~/.zshenv.local`,
which `.zshenv` sources if present. Prefer pulling values from 1Password at runtime:

```bash
export SOME_TOKEN="$(op read op://Private/some-item/credential)"
```

SSH keys are held by the 1Password agent (see `.ssh/config`); no private key is ever
written into this repo.
