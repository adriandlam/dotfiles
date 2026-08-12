# ── Startup banner ────────────────────────────────────────────────────────
# Modelled on Nushell's welcome banner (crates/nu-std/std/prelude/mod.nu).
#
# The rule that banner follows, and this one keeps: nothing here depends on the
# current directory. Nushell prints its compiled-in version, literal URLs and
# its own measured startup time, so the output is byte-identical whether you
# launch it in /tmp or inside a repo. Per-directory state is a prompt's job and
# starship already does it — a banner that changed per directory would just be
# a status line that scrolls away.
#
# Where this departs from Nushell: its banner is a greeting for a public
# project, so it is all pointers outward (Discord, GitHub, docs) and one vanity
# stat. On your own machine those are things you already know, and a banner you
# read 50 times a day stops being read at all. So every field here is something
# that *changes*, and each one colours itself only when it crosses a threshold —
# steady state is a block you can skip, and anything worth acting on is yellow.
#
# Named `motd`, not `banner`, because /usr/bin/banner already exists.

# Four roles, in the Linear palette used everywhere else in this repo. The
# split that matters is label vs value: the label is scaffolding you read once
# and then navigate by, the value is the thing you actually came for, so the
# value sits at full foreground brightness and everything around it recedes.
# An earlier pass had labels at #636b7b and values at #b5bccb — the comment and
# path colours — which left the whole block below foreground brightness and
# reading as washed out.
typeset -g _MOTD_LABEL=$'\e[38;2;99;107;123m'     # #636b7b  labels, recede
typeset -g _MOTD_SEP=$'\e[38;2;99;107;123m'       # #636b7b  separators
typeset -g _MOTD_VALUE=$'\e[38;2;230;233;239m'    # #e6e9ef  values, full fg
typeset -g _MOTD_ACCENT=$'\e[38;2;140;151;255m'   # #8c97ff  emphasis, sparingly
typeset -g _MOTD_WARN=$'\e[38;2;245;197;106m'     # #f5c56a  over threshold
typeset -g _MOTD_ALERT=$'\e[38;2;255;126;120m'    # #ff7e78  outright failing

# Thresholds. Above/below these, the value turns yellow.
typeset -g _MOTD_UPTIME_WARN_DAYS=7
typeset -g _MOTD_DISK_WARN_GB=25

# How stale the brew count may get before a refresh is kicked off. Formulae do
# not go out of date on a timescale where six hours matters.
typeset -g _MOTD_BREW_TTL=21600

# doctor.sh takes ~7s (it scans full git history with gitleaks and checks the
# Brewfile), so it runs far more rarely and never anywhere near the hot path.
typeset -g _MOTD_DOCTOR="$HOME/dotfiles/doctor.sh"
typeset -g _MOTD_DOCTOR_TTL=86400

# sw_vers is a 4.6ms fork, so cache it. The plist is the file sw_vers itself
# reads, which makes its mtime the exact invalidation signal — it changes on an
# OS update and at no other time. Sets a global instead of echoing, because a
# command substitution would fork the very subshell this is avoiding.
_motd_os_version() {
  local plist=/System/Library/CoreServices/SystemVersion.plist
  local cache="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles/os-version"

  if [[ ! -s $cache || $plist -nt $cache ]]; then
    mkdir -p "${cache:h}"
    sw_vers -productVersion >| "$cache" 2>/dev/null
  fi

  # $(<file) is read by the shell itself — no fork, unlike $(cat file).
  typeset -g _MOTD_OS="$(<$cache)"
}

# kern.boottime prints "{ sec = 1725000000, usec = 123456 } Mon Aug ...", so
# peel the seconds out of the middle with parameter expansion rather than an
# awk/sed pipe. 1.3ms, cheap enough to run every time.
_motd_uptime() {
  typeset -g _MOTD_UPTIME="" _MOTD_UPTIME_HOT=0

  local raw
  raw=$(sysctl -n kern.boottime 2>/dev/null) || return 0
  [[ $raw == *"sec = "* ]] || return 0

  local -i boot=${${raw#*sec = }%%,*}
  (( boot > 0 )) || return 0

  local -i secs=$(( EPOCHSECONDS - boot ))
  (( secs > 0 )) || return 0

  local -i d=$(( secs / 86400 )) h=$(( secs % 86400 / 3600 )) m=$(( secs % 3600 / 60 ))

  if (( d )); then
    typeset -g _MOTD_UPTIME="${d}d ${h}h"
  elif (( h )); then
    typeset -g _MOTD_UPTIME="${h}h ${m}m"
  else
    typeset -g _MOTD_UPTIME="${m}m"
  fi

  (( d >= _MOTD_UPTIME_WARN_DAYS )) && typeset -g _MOTD_UPTIME_HOT=1
  return 0
}

# df -k prints a header then one row: Filesystem 1024-blocks Used Available ...
# Splitting the row on whitespace is exact here — the only field that can hold
# a space is the mount point, and that is last.
_motd_disk() {
  typeset -g _MOTD_DISK="" _MOTD_DISK_HOT=0

  local -a lines cols
  lines=( ${(f)"$(df -k / 2>/dev/null)"} )
  (( ${#lines} >= 2 )) || return 0
  cols=( ${=lines[2]} )
  (( ${#cols} >= 4 )) || return 0

  local -i avail_k=${cols[4]}
  (( avail_k > 0 )) || return 0

  # Free space only, deliberately not a percentage. APFS volumes share a
  # container, so df's "size" is the container's, not this volume's: on this
  # machine it reads 460Gi size / 12Gi used / 15Gi avail, which reconciles only
  # once you know the other volumes exist. avail/size would render as "3% free"
  # and sit permanently yellow for a reason you cannot act on. Absolute GB is
  # the number that actually means something, so the threshold is absolute too.
  #
  # +524288 rounds to nearest GiB instead of truncating, so this agrees with
  # what `df -h` shows rather than reading one GB lower.
  local -i avail_g=$(( (avail_k + 524288) / 1048576 ))

  typeset -g _MOTD_DISK="${avail_g}G free"
  (( avail_g < _MOTD_DISK_WARN_GB )) && typeset -g _MOTD_DISK_HOT=1
  return 0
}

# `brew outdated` is ~490ms — twice the whole shell startup — so it can never
# run on the path that prints the startup time. Instead the count is read from
# a cache file (instant, no fork), and a refresh is disowned into the
# background only once the cache is older than the TTL. The displayed number is
# therefore up to six hours stale, which is the correct trade: a slightly old
# count costs nothing, a 490ms pause on every new terminal costs everything.
#
# The stamp is written even when brew fails, so a broken brew degrades to one
# silent retry per TTL rather than a spawned job on every single shell.
_motd_brew_refresh() {
  local cache="$1"
  {
    local n
    n=$(brew outdated --quiet 2>/dev/null | wc -l)
    mkdir -p "${cache:h}"
    # Write-then-rename: another shell reading this file concurrently sees
    # either the old contents or the new, never a half-written line.
    print -r -- "$EPOCHSECONDS ${${n//[^0-9]/}:-0}" >| "${cache}.tmp$$"
    mv -f "${cache}.tmp$$" "$cache"
  } &!
}

_motd_brew() {
  typeset -g _MOTD_BREW=""
  (( $+commands[brew] )) || return 0

  local cache="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles/brew-outdated"
  local -i stamp=0 count=0

  if [[ -s $cache ]]; then
    local -a parts=( ${=$(<$cache)} )
    stamp=${parts[1]:-0}
    count=${parts[2]:-0}
  fi

  (( EPOCHSECONDS - stamp > _MOTD_BREW_TTL )) && _motd_brew_refresh "$cache"

  # Unlike uptime and disk, zero carries no information — "0 outdated" is a
  # line you would learn to skip. Shown only when there is something to do.
  (( count > 0 )) && typeset -g _MOTD_BREW="${count} outdated"
  return 0
}

# The point of a health check you never remember to run is that it tells you
# nothing. This surfaces doctor.sh's own summary line, cached exactly like the
# brew count — the difference being a 24h TTL, because a 7s background job is
# not something to kick off several times a day.
#
# Failures and warnings are kept apart because they mean different things: a
# warning is drift you will get to, a failure is something on this machine that
# is actually broken.
_motd_doctor_refresh() {
  local cache="$1" script="$2"
  {
    local summary
    summary=$("$script" 2>/dev/null | tail -1)
    local -i f=0 w=0
    # The summary carries ANSI bold, so match the digits by their trailing
    # words rather than trying to strip escapes first.
    if [[ $summary =~ '([0-9]+) passed, ([0-9]+) failed, ([0-9]+) warning' ]]; then
      f=${match[2]} w=${match[3]}
    fi
    mkdir -p "${cache:h}"
    print -r -- "$EPOCHSECONDS $f $w" >| "${cache}.tmp$$"
    mv -f "${cache}.tmp$$" "$cache"
  } &!
}

_motd_doctor() {
  typeset -g _MOTD_HEALTH="" _MOTD_HEALTH_BAD=0
  [[ -x $_MOTD_DOCTOR ]] || return 0

  local cache="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles/doctor"
  local -i stamp=0 fails=0 warns=0

  if [[ -s $cache ]]; then
    local -a parts=( ${=$(<$cache)} )
    stamp=${parts[1]:-0}
    fails=${parts[2]:-0}
    warns=${parts[3]:-0}
  fi

  (( EPOCHSECONDS - stamp > _MOTD_DOCTOR_TTL )) && \
    _motd_doctor_refresh "$cache" "$_MOTD_DOCTOR"

  # A clean machine says nothing at all — this line exists to be an exception.
  if (( fails > 0 )); then
    typeset -g _MOTD_HEALTH="${fails} failing"
    (( warns > 0 )) && typeset -g _MOTD_HEALTH="${_MOTD_HEALTH}, ${warns} warning"
    typeset -g _MOTD_HEALTH_BAD=1
  elif (( warns > 0 )); then
    typeset -g _MOTD_HEALTH="${warns} warning"
    (( warns > 1 )) && typeset -g _MOTD_HEALTH="${warns} warnings"
  fi
  return 0
}

# --short mirrors Nushell's `banner --short`: startup time only, on the theory
# that it is the one number you cannot reconstruct yourself after the fact.
motd() {
  local label=$_MOTD_LABEL sep=$_MOTD_SEP value=$_MOTD_VALUE
  local accent=$_MOTD_ACCENT warn=$_MOTD_WARN alert=$_MOTD_ALERT
  local reset=$'\e[0m'

  # Nushell drops to `ansi strip` when colour is off; piping into a file is the
  # equivalent condition here.
  if [[ ! -t 1 ]]; then
    label="" sep="" value="" accent="" warn="" alert="" reset=""
  fi

  local startup="${_DOTFILES_STARTUP_MS:-?}ms"

  if [[ $1 == --short || $1 == -s ]]; then
    print -r -- "${label}Startup Time: ${value}${startup}${reset}"
    return 0
  fi

  _motd_os_version
  _motd_uptime
  _motd_disk
  _motd_brew
  _motd_doctor

  # A value sits at full brightness normally and turns yellow once it crosses
  # its threshold, so the steady-state block reads as one even weight and the
  # only thing that changes colour is the thing worth acting on.
  local uptime_colour=$value disk_colour=$value
  (( _MOTD_UPTIME_HOT )) && uptime_colour=$warn
  (( _MOTD_DISK_HOT ))   && disk_colour=$warn

  print -r -- "${value}Welcome back to ${accent}zsh${value}, ${accent}${USER}${value}.${reset}"
  print
  # One emphasis per line at most. This previously accented all four of
  # zsh/macOS/arch/terminal, which is four competing highlights in one line and
  # reads as busy — the values carry themselves, only the dots recede.
  print -r -- "${label}Version:      ${value}zsh ${ZSH_VERSION} ${sep}· ${value}macOS ${_MOTD_OS} ${sep}· ${value}${CPUTYPE} ${sep}· ${value}${TERM_PROGRAM:-terminal}${reset}"
  [[ -n $_MOTD_UPTIME ]] && print -r -- "${label}Uptime:       ${uptime_colour}${_MOTD_UPTIME}${reset}"
  [[ -n $_MOTD_DISK ]]   && print -r -- "${label}Disk:         ${disk_colour}${_MOTD_DISK}${reset}"
  [[ -n $_MOTD_BREW ]]   && print -r -- "${label}Packages:     ${warn}${_MOTD_BREW}${reset}"

  if [[ -n $_MOTD_HEALTH ]]; then
    local health_colour=$warn
    (( _MOTD_HEALTH_BAD )) && health_colour=$alert
    print -r -- "${label}Health:       ${health_colour}${_MOTD_HEALTH}${sep} · doctor.sh${reset}"
  fi

  print -r -- "${label}Startup Time: ${value}${startup}${reset}"
  return 0
}

# The guard Nushell gets from `$nu.is-interactive`, plus an opt-out. Nushell
# prints on every interactive start no matter how deeply nested, and so does
# this; uncomment the SHLVL line to keep nested shells and :terminal splits
# quiet. Do not gate on SHLVL blindly — a terminal launched from a shell can
# start you at SHLVL 2, and the banner would then never appear at all.
_motd_maybe() {
  [[ -o interactive ]] || return 0
  [[ -t 1 ]] || return 0
  [[ ${DOTFILES_BANNER:-1} != 0 ]] || return 0
  # (( SHLVL <= 1 )) || return 0
  motd
}
