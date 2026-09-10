#!/bin/bash
#
# Health check for this dotfiles install.
#
# setup.sh documents a model — most config is symlinked, a few replace-on-write
# files are copied, and four directories must never be folded because they hold
# credentials next to config. Nothing verified that the machine still matches
# the model. This does.
#
# Read-only: it reports, it never repairs.

set -uo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PASS=0 FAIL=0 WARN=0

ok()   { printf '  \033[32m✓\033[0m %s\n' "$1"; PASS=$((PASS + 1)); }
bad()  { printf '  \033[31m✗\033[0m %s\n' "$1"; FAIL=$((FAIL + 1)); }
warn() { printf '  \033[33m!\033[0m %s\n' "$1"; WARN=$((WARN + 1)); }
head_() { printf '\n\033[1m%s\033[0m\n' "$1"; }

# ── Symlinks ──────────────────────────────────────────────────────────────
head_ "Symlinks"

broken=0
while IFS= read -r link; do
    [ -e "$link" ] || { bad "dangling: ${link/#$HOME/\~} -> $(readlink "$link")"; broken=1; }
done < <(find "$HOME" -maxdepth 3 -type l -lname "*dotfiles*" 2>/dev/null)
[ "$broken" -eq 0 ] && ok "no dangling links into the repo"

# ── Stow coverage ─────────────────────────────────────────────────────────
# The check above walks $HOME, so it only ever sees links that already exist —
# a file added to the repo but never stowed creates nothing to iterate over and
# is invisible to it. Not hypothetical: .config/starship.toml sat in the repo
# unlinked, starship fell back to its built-in prompt with no error anywhere,
# and this script still reported all-clear. Detecting an absence needs the repo
# as the source of truth, so ask stow what it would still do. Any LINK it wants
# to make that is not a restow no-op is config $HOME is missing.
head_ "Stow coverage"

if command -v stow >/dev/null 2>&1; then
    unlinked="$(cd "$DOTFILES" && stow -n -v --target="$HOME" --restow . 2>&1 \
        | grep '^LINK:' | grep -v 'reverts previous action' \
        | sed 's/^LINK: //; s/ =>.*//')"
    if [ -z "$unlinked" ]; then
        ok "every stow-managed file is linked into \$HOME"
    else
        while IFS= read -r f; do
            bad "in the repo but not linked into \$HOME: $f"
        done <<< "$unlinked"
        printf '    fix: stow --target="$HOME" --restow .\n'
    fi
else
    warn "stow not installed (brew bundle)"
fi

# ── Fold hazards ──────────────────────────────────────────────────────────
# The load-bearing invariant: these hold credentials and live state beside
# config. If stow ever folds one, the whole directory lands in a public repo.
head_ "Fold hazards"

for d in .claude .codex .agents .ssh .config; do
    if [ -L "$HOME/$d" ]; then
        bad "$d is a SYMLINK — stow folded it; credentials may be exposed"
    elif [ -d "$HOME/$d" ]; then
        ok "$d is a real directory"
    else
        warn "$d does not exist"
    fi
done

# ── Secrets ───────────────────────────────────────────────────────────────
head_ "Secrets"

if command -v gitleaks >/dev/null 2>&1; then
    if gitleaks detect --source "$DOTFILES" --redact --no-banner >/dev/null 2>&1; then
        ok "gitleaks: clean history"
    else
        bad "gitleaks found secrets — run: gitleaks detect --source . --redact"
    fi
else
    warn "gitleaks not installed (brew bundle)"
fi

hooks="$(git -C "$DOTFILES" config --get core.hooksPath || true)"
if [ "$hooks" = ".githooks" ]; then
    ok "pre-commit hook wired (core.hooksPath=.githooks)"
else
    bad "core.hooksPath not set — run: git config core.hooksPath .githooks"
fi

if [ -f "$HOME/.zshenv.local" ]; then
    if git -C "$DOTFILES" check-ignore -q .zshenv.local; then
        ok ".zshenv.local exists and is gitignored"
    else
        bad ".zshenv.local is NOT gitignored"
    fi
else
    warn ".zshenv.local missing — machine-local secrets not configured"
fi

# ── Commit signing ────────────────────────────────────────────────────────
# Signing and verifying are separate halves; only this exercises the second.
head_ "Commit signing"

if [ "$(git -C "$DOTFILES" config --get commit.gpgsign || true)" = "true" ]; then
    ok "commit.gpgsign enabled"

    # Check the newest commit *you* committed, not HEAD. Merging a PR on
    # github.com leaves a commit authored as you but committed by
    # "GitHub <noreply@github.com>" and signed with GitHub's PGP key — so it is
    # signed, just not by you, and verifying it needs gpg installed. Checking
    # HEAD therefore reported "unsigned" on a perfectly healthy machine.
    #
    # Filter on the committer, not the author: the author survives a web-UI
    # merge, and such a commit is single-parent, so neither --author nor
    # --no-merges excludes it. stderr is dropped because git prints
    # "cannot run gpg" as it walks past those foreign PGP signatures.
    SIGN_EMAIL="$(git -C "$DOTFILES" config --get user.email || true)"
    SIGN_REF="$(git -C "$DOTFILES" log --committer="$SIGN_EMAIL" \
        --pretty='%G?' -1 2>/dev/null)"

    case "$SIGN_REF" in
        G) ok "latest self-committed commit verifies" ;;
        N) bad "latest self-committed commit is unsigned" ;;
        B) bad "latest self-committed commit signature is BAD" ;;
        "") warn "no commits committed by $SIGN_EMAIL to verify" ;;
        *) bad "signature does not verify — check gpg.ssh.allowedSignersFile" ;;
    esac
else
    warn "commit signing disabled"
fi

# ── Packages ──────────────────────────────────────────────────────────────
head_ "Packages"

if command -v brew >/dev/null 2>&1; then
    if brew bundle check --file="$DOTFILES/Brewfile" >/dev/null 2>&1; then
        ok "Brewfile satisfied"
    else
        # `check --verbose` lists each unmet entry as "→ Formula x needs to be
        # installed or updated." Outdated counts as unmet, so this is usually
        # drift rather than anything missing.
        # 2>&1, not 2>/dev/null: brew writes the per-entry "→ Formula x needs
        # to be ..." lines to stderr, so discarding it counts zero every time.
        drift="$(brew bundle check --verbose --file="$DOTFILES/Brewfile" 2>&1 \
            | grep -c '^→ ' || true)"
        warn "Brewfile drift: ${drift} entries outdated or missing — run: brew bundle"
    fi
else
    bad "brew not installed"
fi

# Homebrew must win over the system for anything it also ships. See the PATH
# block in .zshrc for why this can silently regress.
shadowed=""
for n in jq openssl python3 nc; do
    resolved="$(zsh -l -i -c "whence $n" 2>/dev/null | head -1)"
    case "$resolved" in
        /opt/homebrew/*|/usr/local/Cellar/*) ;;
        "") ;;
        *) shadowed="$shadowed $n" ;;
    esac
done
if [ -n "$shadowed" ]; then
    bad "system binaries shadow Homebrew:$shadowed — check the PATH block in .zshrc"
else
    ok "Homebrew precedes the system on PATH"
fi

# ── Fonts ─────────────────────────────────────────────────────────────────
# Same silent-fallback shape as the stow gap above: name a family that is not
# installed and Ghostty quietly uses its bundled font instead, so the config
# reads as applied and is not. Cask names are not family names — the Brewfile's
# font-geist-mono-nerd-font installs "GeistMono Nerd Font Mono" — which is
# exactly how the two drift apart. +list-fonts prints families unindented.
head_ "Fonts"

ghostty_bin=/Applications/Ghostty.app/Contents/MacOS/ghostty
if [ -x "$ghostty_bin" ]; then
    want="$(sed -n 's/^font-family[[:space:]]*=[[:space:]]*//p' \
        "$DOTFILES/.config/ghostty/config" | head -1 | sed 's/^"//; s/"$//')"
    if [ -z "$want" ]; then
        ok "ghostty: no font-family set (uses the bundled default)"
    elif "$ghostty_bin" +list-fonts 2>/dev/null | grep -qxF "$want"; then
        ok "ghostty font installed: $want"
    else
        bad "ghostty font-family \"$want\" is not installed — silently falling back"
    fi
else
    warn "Ghostty not installed"
fi

# ── Keyboard ──────────────────────────────────────────────────────────────
# Same silent-fallback shape as the font check above. macos-defaults.sh writes
# thirty shortcut entries; re-listing all thirty here would only duplicate that
# table somewhere it can quietly drift from it. What earns a check is the handful
# whose regression is silent and misleading: System Settings rewrites the whole
# symbolichotkeys domain whenever you open a shortcut pane, and it hands ⌘Space
# back to Spotlight on the way out. The symptom reads as "Raycast stopped
# working", never as a settings change — so nothing points you here.
#
# Read through `defaults export`, not the plist on disk: cfprefsd holds writes in
# memory and flushes lazily, so the file is stale for minutes after a change and
# a direct read reports drift that does not exist.
head_ "Keyboard"

if [[ "$OSTYPE" == "darwin"* ]]; then
    SHK="$(mktemp)"
    trap 'rm -f "$SHK"' EXIT

    # Whole entry, then match on the printed form — PlistBuddy's boolean output
    # is not reliably capturable field-by-field across macOS releases.
    hk_entry() { /usr/libexec/PlistBuddy -c "Print :AppleSymbolicHotKeys:$1" "$SHK" 2>/dev/null; }

    hk_check() {  # hk_check <id> <enabled|disabled> <description>
        local entry state
        entry="$(hk_entry "$1")"
        case "$entry" in
            "")                  warn "hotkey $1 absent — $3"; return ;;
            *"enabled = true"*)  state=enabled ;;
            *"enabled = false"*) state=disabled ;;
            *)                   warn "hotkey $1 unreadable — $3"; return ;;
        esac
        if [ "$state" = "$2" ]; then
            ok "$3"
        else
            bad "$3 — but hotkey $1 is ${state}"
        fi
    }

    if defaults export com.apple.symbolichotkeys - > "$SHK" 2>/dev/null; then
        hk_check 64 disabled "Spotlight unbound — ⌘Space is Raycast's"
        hk_check 65 disabled "Finder search unbound — ⌥⌘Space is free"
        hk_check 60 disabled "input-source switching unbound — ⌃Space is free"
        hk_check 31 enabled  "⇧⌘S copies the selected area to the clipboard"

        # Enabled is only half of it: the binding itself can be reassigned while
        # the entry stays on, which is exactly what happens if you set ⇧⌘S
        # somewhere else and let System Settings resolve the conflict.
        # PlistBuddy prints the array one element per line; stripping whitespace
        # concatenates [115, 1, 1179648] — ascii "s", keycode S, ⇧⌘ — into the
        # digits below. Crude, but it needs no plist parser in a bash script.
        params="$(/usr/libexec/PlistBuddy -c "Print :AppleSymbolicHotKeys:31:value:parameters" \
            "$SHK" 2>/dev/null | tr -d ' \n')"
        case "$params" in
            *"11511179648"*) ok "hotkey 31 still bound to ⇧⌘S" ;;
            "")              warn "hotkey 31 has no binding recorded" ;;
            *)               bad "hotkey 31 is no longer ⇧⌘S — run ./macos-defaults.sh" ;;
        esac
    else
        warn "could not read com.apple.symbolichotkeys"
    fi

    # Caps Lock → Escape. Checked on the internal keyboard only: external ones
    # get their own vendor-product entry and are absent whenever unplugged, so
    # a missing entry there is not evidence of anything.
    if defaults -currentHost read -g "com.apple.keyboard.modifiermapping.0-0-0" 2>/dev/null \
        | grep -q 30064771113; then
        ok "Caps Lock → Escape on the internal keyboard"
    else
        bad "Caps Lock is not remapped — run ./macos-defaults.sh"
    fi
else
    warn "not macOS — keyboard checks skipped"
fi

# ── Shell ─────────────────────────────────────────────────────────────────
head_ "Shell"

zsh -n "$DOTFILES/.zshrc" 2>/dev/null \
    && ok ".zshrc parses" \
    || bad ".zshrc has a syntax error"

for s in setup.sh snapshot.sh macos-defaults.sh doctor.sh .githooks/pre-commit; do
    [ -f "$DOTFILES/$s" ] || continue
    bash -n "$DOTFILES/$s" 2>/dev/null \
        && ok "$s parses" \
        || bad "$s has a syntax error"
done

# ── Summary ───────────────────────────────────────────────────────────────
printf '\n\033[1m%d passed, %d failed, %d warnings\033[0m\n' "$PASS" "$FAIL" "$WARN"
[ "$FAIL" -eq 0 ]
