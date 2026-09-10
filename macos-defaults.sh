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

# ── Key remapping ─────────────────────────────────────────────────────────
head_ "Key remapping"

# Caps Lock → Escape. System Settings → Keyboard → Modifier Keys writes this into
# the *per-host* global domain (defaults -currentHost read -g), one entry per
# keyboard, keyed com.apple.keyboard.modifiermapping.<vendorID>-<productID>-0.
# The values are HID usage codes: 0x700000039 is Caps Lock, 0x700000029 Escape.
#
# Not hidutil. Every write-up on this reaches for `hidutil property --set`, but
# that mapping lives in the driver and is gone on the next reboot — persisting it
# needs a LaunchDaemon wrapper around it. The pref below is what the GUI itself
# writes, so it survives reboots and reads back correctly in System Settings.
CAPS_LOCK=30064771129   # 0x700000039
ESCAPE=30064771113      # 0x700000029

remap_caps_to_escape() {
    defaults -currentHost write -g "com.apple.keyboard.modifiermapping.$1" -array \
        "<dict>
            <key>HIDKeyboardModifierMappingDst</key><integer>${ESCAPE}</integer>
            <key>HIDKeyboardModifierMappingSrc</key><integer>${CAPS_LOCK}</integer>
        </dict>"
}

# 0-0-0 is the Apple Internal Keyboard / Trackpad. Every external keyboard gets
# its own entry, and ioreg can only see one while it is plugged in — so remap
# whatever is attached right now, and name 13364-2800 (0x3434/0xaf0, the
# Keychron) explicitly so a run with it unplugged still covers it.
KEYBOARDS="$({ printf '0-0-0\n13364-2800-0\n'
    ioreg -c AppleHIDKeyboardEventDriverV2 -r -d 1 2>/dev/null \
        | awk -F' = ' '/"VendorID"/ {v=$2}
                       /"ProductID"/ {if (v != "") {print v "-" $2 "-0"; v=""}}'
} | sort -u)"

for kb in $KEYBOARDS; do
    remap_caps_to_escape "$kb"
done
ok "Caps Lock → Escape on: $(printf '%s' "$KEYBOARDS" | tr '\n' ' ')"

# ── Keyboard shortcuts ────────────────────────────────────────────────────
head_ "Keyboard shortcuts"

# Everything under System Settings → Keyboard → Keyboard Shortcuts lives in one
# dictionary, com.apple.symbolichotkeys:AppleSymbolicHotKeys, keyed by an opaque
# integer per action. Apple never published those IDs; the names in the comments
# below are the community-mapped values, each read back off this machine.
#
# `parameters` is [ascii, keycode, modifierMask]. 65535 in the ascii slot means
# the key has no printable character (arrows, F-keys). The mask is a bitfield:
#   shift 1<<17 = 131072      control 1<<18 = 262144    option 1<<19 = 524288
#   command 1<<20 = 1048576   fn 1<<23 = 8388608
#
# -dict-add rather than `defaults import` of an exported plist: it merges, so an
# ID a later macOS introduces keeps its own default instead of being wiped by a
# stale blob, and the table stays legible. The tradeoff is that each call must
# write the *whole* {enabled, value} dict — writing `enabled` alone replaces the
# entry and drops the binding, and macOS then restores its stock shortcut.
hotkey() {  # hotkey <id> <on|off> [ascii keycode modifiers]
    local id="$1" state="$2" flag body=""
    [ "$state" = "on" ] && flag="true" || flag="false"
    if [ "$#" -eq 5 ]; then
        body="<key>value</key><dict>
                <key>parameters</key>
                <array><integer>$3</integer><integer>$4</integer><integer>$5</integer></array>
                <key>type</key><string>standard</string>
              </dict>"
    fi
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add "$id" \
        "<dict><key>enabled</key><${flag}/>${body}</dict>"
}

# Spotlight and Finder search off, so Raycast owns ⌘Space
hotkey 64 off 32 49 1048576     # ⌘Space   Show Spotlight search
hotkey 65 off 32 49 1572864     # ⌥⌘Space  Show Finder search window
ok "Spotlight and Finder search unbound, ⌘Space freed for Raycast"

# Input-source switching, which otherwise swallows ⌃Space system-wide
hotkey 60 off 32 49 262144      # ⌃Space   Select the previous input source
hotkey 61 off 32 49 786432      # ⌃⌥Space  Select next source in Input menu
ok "input-source switching unbound, ⌃Space freed"

# Apple's screenshot shortcuts off, replaced by the single binding we use: ⇧⌘S
# copies the selected area to the clipboard. Nothing writes to disk any more.
hotkey 28  off 51  20 1179648   # ⇧⌘3  Save picture of screen as file
hotkey 29  off 115  1 1179648   # ⇧⌘S  Copy picture of screen to clipboard
hotkey 30  off 52  21 1179648   # ⇧⌘4  Save picture of selected area as file
hotkey 184 off 53  23 1179648   # ⇧⌘5  Screenshot and recording options
hotkey 31  on  115  1 1179648   # ⇧⌘S  Copy picture of selected area to clipboard
ok "screenshots: only ⇧⌘S, copying the selected area to the clipboard"

# Mission Control on ⌃fn↑ / ⌃fn↓ rather than the stock ⌃↑ / ⌃↓
hotkey 32 on 65535 126 8650752  # ⌃fn↑   Mission Control
hotkey 33 on 65535 125 8650752  # ⌃fn↓   Application windows
hotkey 34 on 65535 126 8781824  # ⇧⌃fn↑  Mission Control, alternate
hotkey 35 on 65535 125 8781824  # ⇧⌃fn↓  Application windows, alternate
ok "Mission Control and Application Windows on ⌃fn↑ / ⌃fn↓"

# Accessibility zoom, contrast and colour inversion. These carry no binding of
# their own in the plist — only an enabled flag — so they take the short form.
for id in 15 16 17 18 19 20 21 22 23 24 25 26; do hotkey "$id" off; done
ok "zoom, contrast and invert-colours shortcuts off"

hotkey 164 off 65535 65535 0    # Turn Do Not Disturb on/off

# Quick Note is the one entry that fits neither form the helper takes: it carries
# a `type` of SAE1.0 and no `parameters` at all. Written out by hand so the plist
# round-trips byte for byte — `hotkey 176 off` would drop the value dict, which
# is harmless in effect but leaves the script unable to reproduce the state it
# claims, and reproducibility is what makes a doctor.sh-style check possible.
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 176 \
    "<dict><key>enabled</key><false/>
     <key>value</key><dict><key>type</key><string>SAE1.0</string></dict></dict>"
ok "Do Not Disturb and Quick Note shortcuts off"

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

# The Dock's contents, in order. Each tile in com.apple.dock is a nested dict
# carrying a GUID, a bookmark blob, a label and a type — not something worth
# hand-writing as `defaults write` XML. dockutil builds them correctly.
#
# The Downloads stack is listed here too, and not as an afterthought: dockutil
# has no way to clear only the apps section, so `--remove all` takes the stack
# with it. Anything the Dock should end up holding has to be in this list or it
# is destroyed on the first rebuild.
#
# --no-restart on every call, with one killall at the end of the script: without
# it a fresh setup flickers through eleven Dock relaunches.
DOCK_APPS=(
    "/Applications/Helium.app"
    "/Applications/Aside.app"
    "/Applications/Dia.app"
    "/System/Applications/Messages.app"
    "/Applications/Notion Calendar.app"
    "/Applications/Spotify.app"
    "/Applications/Ghostty.app"
    "/Applications/Zed.app"
    "/Applications/Claude.app"
    "/Applications/ChatGPT.app"
)

if ! command -v dockutil >/dev/null 2>&1; then
    skip "dockutil not installed (brew bundle) — Dock left alone"
else
    # dockutil --list prints "label<TAB>url<TAB>section<TAB>plist[<TAB>bundleid]".
    # Field 2 is a file:// URL with a trailing slash and percent-escapes; the
    # printf '%b' trick decodes %20 and friends without reaching for python.
    current="$(dockutil --list 2>/dev/null | cut -f2 | sed 's|^file://||; s|/$||')"
    current="$(printf '%b' "${current//%/\\x}")"
    wanted="$(printf '%s\n' "${DOCK_APPS[@]}" "$HOME/Downloads")"

    if [ "$current" = "$wanted" ]; then
        info "Dock already matches (${#DOCK_APPS[@]} apps and the Downloads stack)"
    else
        # Refuse to rebuild if anything is missing. --remove all is destructive,
        # and a half-populated Dock on a machine mid-install is worse than the
        # one macOS shipped: the apps you do have would be silently dropped.
        missing=""
        for app in "${DOCK_APPS[@]}"; do
            [ -e "$app" ] || missing="$missing ${app##*/}"
        done
        if [ -n "$missing" ]; then
            skip "Dock left alone — not installed yet:$missing"
        else
            dockutil --remove all --no-restart >/dev/null 2>&1 || true
            for app in "${DOCK_APPS[@]}"; do
                dockutil --add "$app" --no-restart >/dev/null 2>&1
            done
            # Matches the live stack: fan view, shown as a stack, newest first.
            dockutil --add "$HOME/Downloads" --view fan --display stack \
                --sort dateadded --no-restart >/dev/null 2>&1
            ok "Dock rebuilt: ${#DOCK_APPS[@]} apps, then the Downloads stack"
        fi
    fi
fi

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

# Reloads the shortcut and modifier-key tables into the running WindowServer.
# Without it the symbolichotkeys writes above sit in the plist unread, and the
# machine keeps answering ⌘Space with Spotlight until the next logout.
ACTIVATE=/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings
if [ -x "$ACTIVATE" ]; then
    "$ACTIVATE" -u
    ok "keyboard shortcuts and key remapping applied to the running session"
else
    skip "activateSettings missing — shortcuts apply after a logout"
fi

info "trackpad and animation changes need a logout to take effect"

# ── Summary ───────────────────────────────────────────────────────────────
printf '\n\033[1m%d settings applied, %d skipped\033[0m\n' "$APPLIED" "$SKIPPED"
