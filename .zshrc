# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"


# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="robbyrussell"
ZSH_THEME=""

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(gitfast httpie iterm2 macos web-search docker dotenv keychain git-commit gitignore zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
alias zshconfig="nvim ~/.zshrc"
alias ohmyzsh="nvim ~/.oh-my-zsh"
alias nv="nvim"

eval "$(rbenv init -)"
export PATH="$HOME/.rbenv/shims:$PATH"

export PATH="/Users/adrianlam/Documents/flutter/bin:$PATH"

# pnpm
export PNPM_HOME="/Users/adrianlam/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# sst
export PATH=/Users/adrianlam/.sst/bin:$PATH

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/opt/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/opt/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /Users/adrianlam/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=header,grid --line-range :500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always | head -200'"

_ifzf_comprun() {
  local command=$1
  shift
  
  case "$command" in
    cd) fzf --preview 'eza --tree --color=always | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo \$' {}" "$@" ;;
    ssh) fzf --preview 'dig {}' "$@" ;;
    *) fzf --preview 'bat --color=always --style=header,grid --line-range :500 {}' "$@" ;;
  esac
}

# Bat (better cat) theme
export BAT_THEME="tokyonight_moon"

# eza alias 
alias ls="eza --color=always --long --git --no-filesize --icons=always --no-user --no-permissions"

# thefuck alias
eval $(thefuck --alias)
eval $(thefuck --alias fk)

# zoxide (better cd)
eval "$(zoxide init zsh)"

alias cd="z"
# source /opt/homebrew/opt/spaceship/spaceship.zsh

# pure prompt
autoload -U promptinit; promptinit

# Tokyo Night color scheme for Pure prompt
# zstyle :prompt:pure:path color '#7AA2F7'          # Tokyo Night's bright blue
# zstyle :prompt:pure:git:branch color '#BB9AF7'    # Tokyo Night's purple
# zstayle :prompt:pure:git:dirty color '#E0AF68'     # Tokyo Night's yellow/orange
# zstyle :prompt:pure:git:arrow color '#E0AF68'     # Matching arrow to dirty indicator
# # zstyle ':prompt:pure:prompt:success' color '#7AA2F7'  # Blue prompt
# zstyle ':prompt:pure:prompt:error' color '#F7768E'    # Tokyo Night's red
# zstyle :prompt:pure:git:stash show yes            # Enable git stash indicator
# zstyle :prompt:pure:git:stash color '#89DDFF'     # Tokyo Night's cyan
# zstysle :prompt:pure:virtualenv color '#7AA2F7'
zstyle :prompt:pure:prompt:success color '#BB9AF7'

# tokyo night's comment is '#4C566A'

alias c2p="code2prompt -l"

# prompt pure

export PATH="$HOME/.local/bin:$PATH"

# Added by Windsurf
export PATH="/Users/adrianlam/.codeium/windsurf/bin:$PATH"

# Added by Windsurf
export PATH="/Users/adrianlam/.codeium/windsurf/bin:$PATH"

# Added by Windsurf
export PATH="/Users/adrianlam/.codeium/windsurf/bin:$PATH"
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# bun completions
[ -s "/Users/adrianlam/.bun/_bun" ] && source "/Users/adrianlam/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
