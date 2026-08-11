export ZSH="$HOME/.oh-my-zsh"

# ── History ───────────────────────────────────────────────────────────────
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_IGNORE_SPACE

# ── Oh My Zsh ─────────────────────────────────────────────────────────────
# Prompt comes from pure, not an omz theme.
ZSH_THEME=""
COMPLETION_WAITING_DOTS="true"

# zsh-autosuggestions and fast-syntax-highlighting are installed by Homebrew and
# sourced below, so they are deliberately absent here.
#
# `dotenv` is deliberately absent too: it sources any .env in a directory you cd
# into, which means `cd` into a cloned repo runs whatever that file contains.
# direnv (hooked in below) does the same job but requires `direnv allow` per
# directory, so a fresh checkout can't execute anything.
#
# `command-not-found` is absent because on macOS it only wires up a handler from
# the homebrew-command-not-found tap, which isn't installed — it loaded and did
# nothing. `alias-finder` is absent because it registers a preexec hook that
# greps the whole alias table before every command you run.
#
# fzf, zoxide and eza have omz plugins too, but all three are configured by hand
# further down with custom widgets and themes; the plugins would overwrite them.
plugins=(
  git gitfast macos brew
  aliases sudo extract copypath copyfile
  colored-man-pages jsontools web-search
  safe-paste magic-enter
  1password gh bun uv golang
)

# Bare Enter runs these instead of a blank prompt. The stock "other" command is
# `ls -lh .`, which collides with the eza alias below (duplicate -l, and eza
# reads -h as --header), so point it at the alias itself.
MAGIC_ENTER_GIT_COMMAND='git status -u .'
MAGIC_ENTER_OTHER_COMMAND='ls'

source $ZSH/oh-my-zsh.sh

# ── PATH: Homebrew ahead of the system ────────────────────────────────────
# Homebrew is on PATH via /etc/paths.d/homebrew rather than a shellenv eval in
# .zprofile. path_helper reads /etc/paths first (/usr/bin, /bin, /usr/sbin,
# /sbin) and only then /etc/paths.d/*, so every brew binary lands *behind* its
# system namesake — openssl, python3, jq and nc all resolved to Apple's build
# despite being installed deliberately.
#
# HOMEBREW_PREFIX is exported by the omz brew plugin above, so this has to come
# after the oh-my-zsh source.
if [[ -n $HOMEBREW_PREFIX ]]; then
  path=("$HOMEBREW_PREFIX/bin" "$HOMEBREW_PREFIX/sbin" ${path:#($HOMEBREW_PREFIX/bin|$HOMEBREW_PREFIX/sbin)})
fi

# ── eza ───────────────────────────────────────────────────────────────────
# Point eza at the repo config, and drop the LS_COLORS omz just set so
# theme.yml wins.
export EZA_CONFIG_DIR="$HOME/.config/eza"
unset LS_COLORS
# unset LS_COLORS also uncolors tab completion, so restore it in Linear colors.
zstyle ':completion:*' list-colors 'di=38;2;140;151;255' 'ln=38;2;245;197;106' 'ex=38;2;140;151;255;1'

# ── Syntax highlighting (Linear) ──────────────────────────────────────────
source $HOMEBREW_PREFIX/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

FAST_HIGHLIGHT_STYLES[command]='fg=#8c97ff'           # accent - commands
FAST_HIGHLIGHT_STYLES[alias]='fg=#8c97ff'             # accent - aliases
FAST_HIGHLIGHT_STYLES[suffix-alias]='fg=#8c97ff'      # accent - suffix aliases
FAST_HIGHLIGHT_STYLES[builtin]='fg=#8c97ff'           # accent - builtins
FAST_HIGHLIGHT_STYLES[function]='fg=#8c97ff'          # accent - functions
FAST_HIGHLIGHT_STYLES[precommand]='fg=#8c97ff'        # accent - precommands (sudo, etc)
FAST_HIGHLIGHT_STYLES[hashed-command]='fg=#8c97ff'    # accent - hashed commands
FAST_HIGHLIGHT_STYLES[single-sq-bracket]='fg=#c2a1ff' # purple - [ ]
FAST_HIGHLIGHT_STYLES[double-sq-bracket]='fg=#c2a1ff' # purple - [[ ]]
FAST_HIGHLIGHT_STYLES[assign-array-bracket]='fg=#c2a1ff'
FAST_HIGHLIGHT_STYLES[case-input]='fg=#c2a1ff'
FAST_HIGHLIGHT_STYLES[subtle-separator]='fg=#c2a1ff'
FAST_HIGHLIGHT_STYLES[bracket-level-1]='fg=#c2a1ff,bold'
FAST_HIGHLIGHT_STYLES[reserved-word]='fg=#f5c56a'     # yellow - reserved words
FAST_HIGHLIGHT_STYLES[subcommand]='fg=#f5c56a'        # yellow - subcommands
FAST_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#f5c56a'  # yellow - 'strings'
FAST_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#f5c56a'  # yellow - "strings"
FAST_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#f5c56a'  # yellow - $'strings'
FAST_HIGHLIGHT_STYLES[double-paren]='fg=#f5c56a'      # yellow - (( ))
FAST_HIGHLIGHT_STYLES[for-loop-operator]='fg=#f5c56a'
FAST_HIGHLIGHT_STYLES[for-loop-separator]='fg=#f5c56a,bold'
FAST_HIGHLIGHT_STYLES[case-parentheses]='fg=#f5c56a'
FAST_HIGHLIGHT_STYLES[here-string-tri]='fg=#f5c56a'
FAST_HIGHLIGHT_STYLES[bracket-level-2]='fg=#f5c56a,bold'
FAST_HIGHLIGHT_STYLES[unknown-token]='fg=#ff7e78,bold' # red - errors
FAST_HIGHLIGHT_STYLES[incorrect-subtle]='fg=#ff7e78'
FAST_HIGHLIGHT_STYLES[matherr]='fg=#ff7e78'
FAST_HIGHLIGHT_STYLES[path]='fg=#b5bccb'              # muted gray - paths
FAST_HIGHLIGHT_STYLES[path-to-dir]='fg=#b5bccb,underline'
FAST_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#636b7b'  # dim gray - options
FAST_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#636b7b'
FAST_HIGHLIGHT_STYLES[back-or-dollar-double-quoted-argument]='fg=#c2a1ff'
FAST_HIGHLIGHT_STYLES[back-dollar-quoted-argument]='fg=#c2a1ff'
FAST_HIGHLIGHT_STYLES[bracket-level-3]='fg=#c2a1ff,bold'
FAST_HIGHLIGHT_STYLES[comment]='fg=#636b7b'           # dim gray - comments
FAST_HIGHLIGHT_STYLES[variable]='fg=#f5c56a'          # yellow - variables
FAST_HIGHLIGHT_STYLES[for-loop-number]='fg=#f5c56a'   # yellow - numbers
FAST_HIGHLIGHT_STYLES[mathnum]='fg=#f5c56a'
FAST_HIGHLIGHT_STYLES[mathvar]='fg=#c2a1ff,bold'
FAST_HIGHLIGHT_STYLES[globbing]='fg=#b5bccb,bold'     # gray - globs
FAST_HIGHLIGHT_STYLES[globbing-ext]='fg=#b5bccb'
FAST_HIGHLIGHT_STYLES[history-expansion]='fg=#b5bccb,bold'
FAST_HIGHLIGHT_STYLES[correct-subtle]='fg=#c2a1ff'

# ── Autosuggestions ───────────────────────────────────────────────────────
source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#636b7b'   # dim gray, matches comments

# ── Completion ────────────────────────────────────────────────────────────
# zsh-autocomplete replaces the completion UI, so it must be configured before
# it is sourced and loaded after everything that defines widgets.
zstyle ':autocomplete:*' min-input 3
zstyle ':autocomplete:*' special-dirs true
zstyle ':autocomplete:*' delay 0.5
zstyle ':autocomplete:*' timeout 1.0
zstyle -e ':autocomplete:*:*' list-lines 'reply=( $(( LINES / 3 )) )'

# zsh-autocomplete runs its own compinit from a precmd hook, and unfunctions
# compdef first. A bare compinit prompts via `read -q` when compaudit flags an
# fpath directory, so one stray keystroke aborts it, compdef never returns, and
# every queued `compdef` falls through to command-not-found. `-i` warns instead
# of prompting, which is what oh-my-zsh already does.
zstyle ':autocomplete::compinit' arguments -i

zstyle ':completion:*' keep-prefix true
zstyle ':completion:*:*' matcher-list 'm:{[:lower:]-}={[:upper:]_}' '+r:|[.]=**'
bindkey '^I' menu-complete
bindkey "$terminfo[kcbt]" reverse-menu-complete

source $HOMEBREW_PREFIX/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh

# ── Editor ────────────────────────────────────────────────────────────────
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# ── Aliases and functions ─────────────────────────────────────────────────
alias nv="nvim"
alias ls="eza --color=always --long --git --no-filesize --icons=always --no-user --no-permissions -la"
alias lt="eza --tree --level=2 --icons --git-ignore"
alias p="pnpm"
alias yp="copypath"
alias yf="copyfile"

mkcd() {
  \mkdir -p "$1"
  cd "$1"
}

# lazygit, chdir-ing to wherever you ended up when it exits
unalias gg 2>/dev/null
gg() {
  export LAZYGIT_NEW_DIR_FILE=~/.lazygit/newdir
  lazygit "$@"
  if [ -f $LAZYGIT_NEW_DIR_FILE ]; then
    cd "$(cat $LAZYGIT_NEW_DIR_FILE)"
    rm -f $LAZYGIT_NEW_DIR_FILE > /dev/null
  fi
}

# ── Runtimes ──────────────────────────────────────────────────────────────
# nvm is slow enough to matter at startup, so nothing loads until first use.
export NVM_DIR="$HOME/.nvm"
nvm() {
  unset -f nvm node npm npx
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
  nvm "$@"
}
node() { unset -f node; nvm() { unset -f nvm; [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"; nvm "$@"; }; [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"; node "$@"; }
npm() { unset -f npm; [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"; npm "$@"; }
npx() { unset -f npx; [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"; npx "$@"; }

export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"

export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:$HOME/.hades/bin"

# ── Prompt ────────────────────────────────────────────────────────────────
# Old prompt: Pure (disabled)
# autoload -U promptinit; promptinit
# PURE_PROMPT_SYMBOL=">"
# zstyle :prompt:pure:path color '#8c97ff'
# zstyle :prompt:pure:git:branch color '#c2a1ff'
# zstyle :prompt:pure:git:dirty color '#f5c56a'
# zstyle :prompt:pure:prompt:success color '#8c97ff'
# zstyle :prompt:pure:git:arrow color '#c2a1ff'
# prompt pure

eval "$(starship init zsh)"

# ── Navigation and search ─────────────────────────────────────────────────
eval "$(zoxide init zsh)"

eval "$(fzf --zsh)"
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
export FZF_DEFAULT_OPTS="\
  --color=bg+:#22273a,bg:#17181d,spinner:#c2a1ff,hl:#f5c56a \
  --color=fg:#e6e9ef,header:#636b7b,info:#636b7b,pointer:#8c97ff \
  --color=marker:#8c97ff,fg+:#e6e9ef,prompt:#8c97ff,hl+:#f5c56a \
  --color=selected-bg:#22273a,border:#22273a,gutter:#17181d"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}' --preview-window='right:60%:wrap'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always --icons --level=2 {}' --preview-window='right:50%'"

# Make fzf's cd widget hand off to zoxide instead of builtin cd.
fzf-cd-widget() {
  setopt localoptions pipefail no_aliases 2> /dev/null
  local dir="$(
    FZF_DEFAULT_COMMAND=${FZF_ALT_C_COMMAND:-} \
    FZF_DEFAULT_OPTS=$(__fzf_defaults "--reverse --walker=dir,follow,hidden --scheme=path" "${FZF_ALT_C_OPTS-} +m") \
    FZF_DEFAULT_OPTS_FILE='' $(__fzfcmd) < /dev/tty)"
  if [[ -z "$dir" ]]; then
    zle redisplay
    return 0
  fi
  zle push-line
  BUFFER="z ${(q)dir:a}"
  zle accept-line
  local ret=$?
  unset dir
  zle reset-prompt
  return $ret
}
zle -N fzf-cd-widget

eval "$(atuin init zsh)"

# ── Misc tooling ──────────────────────────────────────────────────────────
# Per-directory env vars, opt-in via `direnv allow`.
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"

if output="$(mole completion zsh 2>/dev/null)"; then eval "$output"; fi

# Syntax-highlighted man pages.
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANROFFOPT="-c"
