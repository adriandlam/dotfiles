#!/bin/bash
#
# macOS defaults for a development machine.
#
# Reports in the same vocabulary as doctor.sh: a bold header per section, one
# indented line per thing actually done or deliberately not done. The helpers
# are duplicated rather than sourced — each script here stays standalone so a
# fresh machine can run any one of them on its own.

set -euo pipefail

APPLIED=0 SKIPPED=0

ok()    { printf '  \033[32m✓\033[0m %s\n' "$1"; APPLIED=$((APPLIED + 1)); }
skip()  { printf '  \033[33m!\033[0m %s\n' "$1"; SKIPPED=$((SKIPPED + 1)); }
info()  { printf '  \033[2m·\033[0m %s\n' "$1"; }
head_() { printf '\n\033[1m%s\033[0m\n' "$1"; }

# ── Preflight ─────────────────────────────────────────────────────────────
# A few settings below need root (chflags on /Volumes, systemsetup). Asking for
# the password up front — and refreshing it in the background — keeps the one
# interactive moment at the start instead of surfacing minutes into setup.sh.
#
# The tty guard matters: without it a non-interactive run (CI, a piped shell)
# blocks forever on a password prompt nobody can answer. Nothing below is
# load-bearing, so skipping sudo entirely just means those few lines no-op.
head_ "Preflight"

if [ -t 0 ] && sudo -v; then
    while true; do
        sudo -n true
        sleep 60
        kill -0 "$$" 2>/dev/null || exit
    done 2>/dev/null &
    SUDO_KEEPALIVE=$!
    trap 'kill "$SUDO_KEEPALIVE" 2>/dev/null || true' EXIT
    ok "sudo cached for this run"
else
    skip "no sudo — /Volumes, restart-on-freeze and Touch ID will be left alone"
fi

# Close System Settings so it cannot overwrite what we write below
osascript -e 'tell application "System Preferences" to quit' 2>/dev/null || true
osascript -e 'tell application "System Settings" to quit' 2>/dev/null || true
info "System Settings closed so it cannot overwrite these values"

# ── Keyboard & input ──────────────────────────────────────────────────────
head_ "Keyboard & input"

# Blazingly fast keyboard repeat (essential for vim/cursor movement)
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 10
ok "key repeat at the fastest rate, shortest delay"

# Disable press-and-hold (we want key repeat for hjkl navigation)
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
ok "press-and-hold off, so hjkl repeats"

# Disable all the "smart" features that mess with code. Quote and dash
# substitution matter most: they turn "foo" into “foo” and -- into –, which
# survives a copy-paste out of Notes or Slack and then fails to parse.
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
ok "smart quotes, dashes, capitalization and periods off"

# Tab through every control in a dialog, not just text fields and lists
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
ok "tab reaches every control in a dialog"

# ── Trackpad & mouse ──────────────────────────────────────────────────────
head_ "Trackpad & mouse"

defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
ok "tap to click"

# ── Finder ────────────────────────────────────────────────────────────────
head_ "Finder"

# Show hidden files (you need to see .gitignore, .env, etc.)
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
ok "hidden files and every filename extension shown"

defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
ok "path bar, status bar and POSIX path in the title"

defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
defaults write com.apple.finder _FXSortFoldersFirst -bool true
ok "list view, search scoped to the current folder, folders first"

defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
ok "no warning when changing a file extension"

# Stop Finder writing .DS_Store onto network shares and USB volumes, which is
# how they end up committed to repos on other people's machines
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
ok ".DS_Store off for network shares and USB volumes"

chflags nohidden ~/Library
ok "the ~/Library folder is visible"

if sudo -n chflags nohidden /Volumes 2>/dev/null; then
    ok "/Volumes visible"
else
    skip "/Volumes left hidden (needs sudo)"
fi

# ── Dock ──────────────────────────────────────────────────────────────────
head_ "Dock"

defaults write com.apple.dock minimize-to-application -bool true
defaults write com.apple.dock show-recents -bool false
ok "minimize into the app icon, recent applications hidden"

# ── Screenshots ───────────────────────────────────────────────────────────
head_ "Screenshots"

mkdir -p "${HOME}/Desktop/Screenshots"
defaults write com.apple.screencapture location -string "${HOME}/Desktop/Screenshots"
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.screencapture disable-shadow -bool true
ok "saved to ~/Desktop/Screenshots as PNG, without the window shadow"

# ── Terminal ──────────────────────────────────────────────────────────────
head_ "Terminal"

defaults write com.apple.terminal SecureKeyboardEntry -bool true
ok "Secure Keyboard Entry on in Terminal.app"

# ── Performance & system ──────────────────────────────────────────────────
head_ "Performance & system"

defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001
ok "window open and resize animations off"

defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true
ok "save and print panels expanded by default"

defaults write com.apple.LaunchServices LSQuarantine -bool false
defaults write com.apple.systempreferences NSQuitAlwaysKeepsWindows -bool false
defaults write com.apple.CrashReporter DialogType -string none
ok "quarantine, Resume and crash reporter dialogs off"

defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
ok "new documents save to disk, not iCloud"

defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true
ok "Time Machine stops offering every new disk"

if sudo -n systemsetup -setrestartfreeze on >/dev/null 2>&1; then
    ok "restart automatically if the machine freezes"
else
    skip "restart-on-freeze unchanged (needs sudo)"
fi

# ── Security ──────────────────────────────────────────────────────────────
head_ "Security"

defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0
ok "password required immediately after sleep or screen saver"

# Touch ID for sudo. /etc/pam.d/sudo_local is the supported seam for this —
# Apple includes it from /etc/pam.d/sudo and, unlike edits to sudo itself,
# it survives system updates. Ships as a .template with the line commented.
if grep -qs '^auth.*pam_tid\.so' /etc/pam.d/sudo_local; then
    info "Touch ID for sudo already enabled"
elif [ -z "${SUDO_KEEPALIVE:-}" ]; then
    skip "Touch ID for sudo (needs an interactive run)"
else
    # Prepend rather than overwrite: the file may already carry unrelated PAM
    # rules, and pam_tid must be reached before sudo falls through to password.
    # The `if` matters: `[ -f x ] && cat x` returns 1 when the file is absent,
    # which under pipefail fails the pipeline and set -e kills the script.
    { printf 'auth       sufficient     pam_tid.so\n'
      if [ -f /etc/pam.d/sudo_local ]; then cat /etc/pam.d/sudo_local; fi
    } | sudo tee /etc/pam.d/sudo_local.new >/dev/null
    sudo mv /etc/pam.d/sudo_local.new /etc/pam.d/sudo_local
    sudo chmod 444 /etc/pam.d/sudo_local
    sudo chown root:wheel /etc/pam.d/sudo_local
    ok "Touch ID for sudo enabled"
fi

# ── Text editing ──────────────────────────────────────────────────────────
head_ "Text editing"

defaults write com.apple.TextEdit RichText -int 0
defaults write com.apple.TextEdit PlainTextEncoding -int 4
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4
ok "TextEdit opens and saves plain text as UTF-8"

# ── Apply ─────────────────────────────────────────────────────────────────
head_ "Applying"

for app in "Dock" "Finder"; do
  killall "${app}" &>/dev/null || true
done
ok "restarted Dock and Finder"

info "keyboard, trackpad and animation changes need a logout to take effect"

# ── Summary ───────────────────────────────────────────────────────────────
printf '\n\033[1m%d settings applied, %d skipped\033[0m\n' "$APPLIED" "$SKIPPED"
