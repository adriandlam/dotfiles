#!/bin/bash

set -euo pipefail

echo "🛠️  Configuring macOS defaults for development..."

# A few settings below need root (chflags on /Volumes, systemsetup). Asking for
# the password up front — and refreshing it in the background — keeps the one
# interactive moment at the start instead of surfacing minutes into setup.sh.
#
# The tty guard matters: without it a non-interactive run (CI, a piped shell)
# blocks forever on a password prompt nobody can answer. Nothing below is
# load-bearing, so skipping sudo entirely just means those few lines no-op.
if [ -t 0 ] && sudo -v; then
    while true; do
        sudo -n true
        sleep 60
        kill -0 "$$" 2>/dev/null || exit
    done 2>/dev/null &
    SUDO_KEEPALIVE=$!
    trap 'kill "$SUDO_KEEPALIVE" 2>/dev/null || true' EXIT
fi

# Close System Preferences to prevent override
osascript -e 'tell application "System Preferences" to quit' 2>/dev/null || true
osascript -e 'tell application "System Settings" to quit' 2>/dev/null || true

# ============================================
# Keyboard & Input (Critical for devs)
# ============================================

echo "⌨️  Configuring keyboard settings..."

# Blazingly fast keyboard repeat (essential for vim/cursor movement)
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 10

# Disable press-and-hold (we want key repeat for hjkl navigation)
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Disable all the "smart" features that mess with code. Quote and dash
# substitution matter most: they turn "foo" into “foo” and -- into –, which
# survives a copy-paste out of Notes or Slack and then fails to parse.
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Tab through every control in a dialog, not just text fields and lists
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# ============================================
# Trackpad & Mouse (Faster = Better)
# ============================================

echo "🖱️  Configuring trackpad/mouse..."

# Enable tap to click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# ============================================
# Finder (Developer-Friendly)
# ============================================

echo "📁 Configuring Finder..."

# Show hidden files (you need to see .gitignore, .env, etc.)
defaults write com.apple.finder AppleShowAllFiles -bool true

# Show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Show path bar (essential for knowing where you are)
defaults write com.apple.finder ShowPathbar -bool true

# Show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Default to list view (easier to scan)
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Search current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Disable warning when changing file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Keep folders on top when sorting
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# Show the full POSIX path in the window title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Stop Finder writing .DS_Store onto network shares and USB volumes, which is
# how they end up committed to repos on other people's machines
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Show ~/Library folder
chflags nohidden ~/Library

# Show /Volumes folder
sudo chflags nohidden /Volumes 2>/dev/null || true

# ============================================
# Dock (Stay Out of the Way)
# ============================================

echo "🎯 Configuring Dock..."

# Minimize windows into application icon
defaults write com.apple.dock minimize-to-application -bool true

# Don't show recent applications
defaults write com.apple.dock show-recents -bool false

# ============================================
# Screenshots (Better Defaults)
# ============================================

echo "📸 Configuring screenshots..."

# Save screenshots to Desktop/Screenshots
mkdir -p "${HOME}/Desktop/Screenshots"
defaults write com.apple.screencapture location -string "${HOME}/Desktop/Screenshots"

# Save as PNG (better quality for docs)
defaults write com.apple.screencapture type -string "png"

# Disable shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool true

# ============================================
# Terminal & Development
# ============================================

echo "💻 Configuring terminal settings..."

# Enable Secure Keyboard Entry in Terminal.app
defaults write com.apple.terminal SecureKeyboardEntry -bool true

# ============================================
# Performance & System
# ============================================

echo "⚡ Configuring system performance..."

# Disable animations when opening applications
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false

# Disable window resize animation
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Expand print panel by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Disable "Are you sure you want to open this application?" dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Disable Resume system-wide (don't restore windows on restart)
defaults write com.apple.systempreferences NSQuitAlwaysKeepsWindows -bool false

# Save new documents to disk, not iCloud
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Don't interrupt with the crash reporter dialog
defaults write com.apple.CrashReporter DialogType -string none

# Restart automatically if the computer freezes
sudo systemsetup -setrestartfreeze on 2>/dev/null || true

# Disable Time Machine prompts for new disks
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

# ============================================
# Security
# ============================================

echo "🔒 Configuring security..."

# Require the password immediately after sleep or screen saver
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# ============================================
# Text Editing
# ============================================

echo "✍️  Configuring text editing..."

# Use plain text mode for new TextEdit documents
defaults write com.apple.TextEdit RichText -int 0

# Open and save files as UTF-8 in TextEdit
defaults write com.apple.TextEdit PlainTextEncoding -int 4
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

# ============================================
# Apply Changes
# ============================================

echo "🔄 Restarting affected applications..."

# Restart affected applications
for app in "Dock" "Finder"; do
  killall "${app}" &>/dev/null || true
done

echo ""
echo "✅ macOS defaults applied!"
echo ""
echo "⚠️  Some changes require a logout/restart:"
echo "   - Keyboard repeat settings"
echo "   - Trackpad settings"
echo "   - Some system animations"
echo ""
echo "💡 Recommended: Log out and back in now"
