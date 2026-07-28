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
    case "$(git -C "$DOTFILES" log --pretty='%G?' -1)" in
        G) ok "HEAD signature verifies" ;;
        N) bad "HEAD is unsigned" ;;
        B) bad "HEAD signature is BAD" ;;
        *) bad "HEAD signature does not verify — check gpg.ssh.allowedSignersFile" ;;
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
