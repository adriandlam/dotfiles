# dotfiles

macOS config, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## New machine

```bash
xcode-select --install                              # git, needed to clone
cd ~ && git clone git@github.com:adriandlam/dotfiles # or https:// before ssh keys exist
cd dotfiles && ./setup.sh
```

`setup.sh` is idempotent — safe to re-run any time. It installs Homebrew if missing,
installs everything in the `Brewfile`, symlinks the tree, and applies the macOS defaults.

Two things it deliberately does not do, because they need you:

1. **1Password** — install the app, sign in, enable the SSH agent. `.ssh/config` already
   points at the agent socket, so git over SSH works once it's running.
2. **`~/.zshenv.local`** — recreate any machine-local secrets. Nothing in this repo
   contains them by design.

## What's here

| Path | Contents |
|---|---|
| `.zshrc`, `.zshenv` | Shell config. Secrets live in `~/.zshenv.local`, which is never committed. |
| `.config/zsh/banner.zsh` | Startup banner, modelled on Nushell's. Disable with `DOTFILES_BANNER=0`; run `motd` to reprint, `motd --short` for startup time only. Caches the OS version, the `brew outdated` count and the `doctor.sh` summary under `~/.cache/dotfiles` — the last two refreshed by disowned background jobs (6h and 24h), never inline. |
| `.gitconfig`, `.config/git` | Git config and delta theme |
| `.config/nvim` | LazyVim. The colorscheme is the [linear-nvim](https://github.com/adriandlam/linear-nvim) plugin, configured in `lua/plugins/colorscheme.lua` |
| `.config/ghostty`, `.config/bat`, `.config/eza`, `.config/lazygit`, `.config/atuin` | Terminal and CLI tooling |
| `.claude`, `.codex`, `.agents` | AI agent config (settings and manifests only — no state, no credentials) |
| `.config/zed` | Zed settings and keymap |
| `.ssh/config` | SSH config only — points at the 1Password agent. No keys, ever. |
| `Brewfile` | Every package, cask, tap and global npm/cargo/go install |
| `macos-defaults.sh` | `defaults write` settings, plus Touch ID for `sudo` |
| `setup.sh`, `snapshot.sh` | Install on a new machine; pull replace-on-write config back in |
| `doctor.sh` | Health check — verifies the install still matches the model below |
| `.githooks`, `.gitleaks.toml` | Pre-commit secret scan and its allowlist |
| `.github/workflows` | CI: shellcheck, a `stow --simulate`, and gitleaks over full history |

## How linking works

`stow --target="$HOME" .` mirrors this tree into `~`. Anything stow must *not* fold is
listed in `.stow-local-ignore` and linked file-by-file at the end of `setup.sh` instead.

That distinction matters: `~/.claude`, `~/.codex`, `~/.agents` and `~/.ssh` all hold live
state and credentials next to their config. Symlinking those directories wholesale would
pull session logs, caches and auth tokens into a public repo. Only individual config files
are linked.

For the same reason `.config/raycast/extensions/` is gitignored: those are bundles
Raycast recompiles on every launch, not config.

### Snapshots

A few files can't be symlinked at all. Claude Code rewrites its plugin manifests by
atomic replace, which deletes a symlink the first time the plugin set changes. Those are
copied on a fresh install and refreshed on demand:

```bash
./snapshot.sh    # pull the live plugin manifests and Brewfile into the repo
```

Everything else is symlinked, so edits land in the repo automatically.

### Checking it still holds

Everything above is a claim about the machine. `./doctor.sh` is what verifies it —
no dangling links, none of the four hazardous directories folded into a symlink,
the pre-commit hook wired, `HEAD`'s signature actually verifying, Homebrew ahead of
the system on `PATH`, and every script parsing. It reports; it never repairs.

```bash
./doctor.sh
```

### Secrets

`.githooks/pre-commit` runs `gitleaks` over the staged changes and refuses the commit
if it finds one. `setup.sh` wires it as a **repo-local** `core.hooksPath` — never
`--global`, which would point every clone on the machine at these hooks. The same scan
runs in CI over the full history.

Allowlist entries in `.gitleaks.toml` should stay narrow. The reason to scan a repo
that deliberately links config sitting beside real credentials is to catch the one
careless `git add`; a broad exclusion quietly turns that off.

## Theming

Everything runs the Linear theme, each tool via its own port:

| Tool | Port |
|---|---|
| Ghostty | [ghostty-linear](https://github.com/adriandlam/ghostty-linear) |
| bat, Sublime | [linear-bat](https://github.com/adriandlam/linear-bat) |
| Zed | [zed-linear](https://github.com/adriandlam/zed-linear) |
| Neovim | [linear-nvim](https://github.com/adriandlam/linear-nvim) |
| delta, lazygit | Inline, in `.gitconfig` and `.config/lazygit` |

Token semantics are shared, so a file reads the same everywhere: keywords indigo
`#8c97ff`, functions purple `#c2a1ff`, types blue `#73b7ff`, strings teal `#7ad9c0`,
numbers yellow `#f5c56a`, punctuation muted `#b5bccb`. Diff backgrounds match the
`[delta]` block in `.gitconfig`, so `git diff` and `:Gdiff` agree.

Neovim pulls `linear-nvim` as a plugin and sets `transparent = true` (the plugin
defaults it off) since Ghostty already paints the same background.

## Shell

oh-my-zsh for its plugin library, [pure](https://github.com/sindresorhus/pure) for the
prompt. The three heavyweight zsh plugins — `zsh-autosuggestions`,
`zsh-fast-syntax-highlighting`, `zsh-autocomplete` — come from the `Brewfile` and are
sourced from `$HOMEBREW_PREFIX` directly, rather than cloned into `$ZSH_CUSTOM`. One
source, and `brew upgrade` keeps them current.

`direnv` handles per-directory environment variables. The oh-my-zsh `dotenv` plugin is
deliberately not enabled: it sources any `.env` in a directory you `cd` into, so cloning
a repo and entering it would run whatever that file contains. `direnv` needs an explicit
`direnv allow` per directory.

## Packages

```bash
brew bundle --file=Brewfile          # install everything
brew bundle dump --force --describe  # rewrite Brewfile from current state
brew bundle cleanup --force          # uninstall anything not in the Brewfile
```

Beyond the usual (`ripgrep`, `fd`, `bat`, `eza`, `fzf`, `zoxide`, `atuin`, `delta`,
`lazygit`, `gh`, `jq`):

| Tool | Replaces | For |
|---|---|---|
| `dust` | `du` | Disk usage as a sorted tree |
| `duf` | `df` | Readable free-space table |
| `btop` | `top` | Process and resource monitor |
| `sd` | `sed s///` | Find and replace with plain regex |
| `yq` | — | `jq` for YAML and TOML |
| `direnv` | — | Per-directory env, opt-in |
| `git-absorb` | manual `--fixup` | Auto-routes changes to the commit that introduced them |
| `watchexec` | — | Re-run a command when files change |

## Secrets

Nothing secret is committed. Machine-local environment variables go in `~/.zshenv.local`,
which `.zshenv` sources if present. Prefer pulling values from 1Password at runtime:

```bash
export SOME_TOKEN="$(op read op://Private/some-item/credential)"
```

SSH keys are held by the 1Password agent (see `.ssh/config`); no private key is ever
written into this repo.
