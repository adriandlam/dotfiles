#!/bin/bash

set -e

echo "🛠️  Configuring macOS defaults for development..."

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

# Disable all the "smart" features that mess with code
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

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

# Restart automatically if the computer freezes
sudo systemsetup -setrestartfreeze on 2>/dev/null || true

# Disable Time Machine prompts for new disks
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

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
    killall "${app}" &> /dev/null || true
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
