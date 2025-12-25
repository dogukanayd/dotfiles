export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export COLORTERM=truecolor
export TERM=xterm-256color   # or 'alacritty'

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
zstyle ':omz:update' mode auto      # update automatically without asking

# Ensure ssh-agent is running and your signing key is loaded

SSH_KEY="$HOME/.ssh/id_ed25519_git_signing"

# If SSH agent not running, start it and export its variables
if [ -z "$SSH_AUTH_SOCK" ] || ! ps -p "$SSH_AGENT_PID" > /dev/null 2>&1; then
  eval "$(ssh-agent -s)" > /dev/null
fi

# Add the signing key if not already added
if ! ssh-add -l | grep -q "$SSH_KEY"; then
  ssh-add "$SSH_KEY" > /dev/null 2>&1
fi


# Ensure VS Code Windows CLI is on PATH when missing
if ! command -v code >/dev/null 2>&1; then
  WIN_LOCALAPPDATA="$(cmd.exe /c echo %LOCALAPPDATA% 2>/dev/null | tr -d '\r')"
  WIN_LOCALAPPDATA_WSL="$(wslpath "$WIN_LOCALAPPDATA" 2>/dev/null)"
  if [ -n "$WIN_LOCALAPPDATA_WSL" ] && [ -d "$WIN_LOCALAPPDATA_WSL/Programs/Microsoft VS Code/bin" ]; then
    export PATH="$PATH:$WIN_LOCALAPPDATA_WSL/Programs/Microsoft VS Code/bin"
  fi
fi

# Automatically set up tmux sessions
# if command -v tmux &> /dev/null; then
#     # Check if tmux is already running
#     if [ -z "$TMUX" ]; then
#         # Function to create a session with two horizontal panes and selectively open NeoVim
#         create_session_with_optional_nvim() {
#             local session_name=$1
#             local dir1=$2
#             local dir2=$3
#             local open_nvim_in_first_pane=$4
#
#             # Create the session if it doesn't exist
#             tmux has-session -t "$session_name" 2>/dev/null || {
#                 if [ "$open_nvim_in_first_pane" = true ]; then
#                     # Start the first pane with NeoVim in the specified directory
#                     tmux new-session -d -s "$session_name" "cd $dir1 && nvim"
#                 else
#                     # Start the first pane as a regular shell in the specified directory
#                     tmux new-session -d -s "$session_name" -c "$dir1"
#                 fi
#                 # Split the window into two horizontal panes with the second pane as a regular shell
#                 tmux split-window -v -t "$session_name" -c "$dir2"
#             }
#         }
#
#         # Create sessions with NeoVim in the first pane only for setup and notes sessions
#         create_session_with_optional_nvim setup "$HOME/dotfiles" "$HOME/dotfiles" true
#         # create_session_with_optional_nvim main "$HOME" "$HOME" false
#         create_session_with_optional_nvim ucd "$HOME" "$HOME" false
#
#         # Attach to the main session
#         #tmux attach-session -t ucd
#     fi
# fi

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"


# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git kube-ps1)

source $ZSH/oh-my-zsh.sh

# Show kubernetes context in right prompt
KUBE_PS1_SYMBOL_ENABLE=false
RPROMPT='$(kube_ps1)'

# User configuration


# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# if operator system is linux
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  # Add brew to PATH
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi


# Alias
alias listen-ports='lsof -i -P -n | grep LISTEN'
alias destroy-docker-images='docker rmi $(docker images -q)'
alias docker-list='docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Ports}}"'
alias docker-kill='docker kill $(docker ps -q)'
alias mockgen="$GOPATH/bin/mockgen"
alias mockgen-usage="echo mockgen -destination=mock_cache.go -package=cache -source=interface.go"
alias http-usage="echo 'http POST http://example.com/api/endpoint < data.json'"
alias docker-clean="docker system prune && docker container prune && docker network prune && docker image prune && docker volume prune"
alias cat="bat"
# alias vimo="nvim $(fzf)"
alias vim="nvim"
alias k="kubectl"
alias aws-login="aws sso --profile atrium login" 
alias ecr-login="aws ecr --profile atrium get-login-password --region eu-west-1 | docker login --username AWS --password-stdin 936289044322.dkr.ecr.eu-west-1.amazonaws.com"
alias kctx="kubectx"

# Function to cd into a directory selected with fzf
fcd() {
    local dir
    dir=$(find "${1:-.}" -type d \( -name .git -o -name vendor \) -prune -false -o -type d 2>/dev/null | fzf --preview 'ls -l {}')
    if [[ -n "$dir" ]]; then
        cd "$dir"
    fi
}

# Functions
lsq() {
  # Set the default level to 1
  level=1

  # If an argument is provided, use it as the level
  if [ -n "$1" ]; then
    level=$1
  fi

  # Run the eza command with the specified level
  eza --color=always --tree --level=$level --long --git --no-filesize --icons=always --no-time --no-user --no-permissions
}

weather () {
  city=${1:-5}
  curl https://wttr.in/$city
}

# Lazy load thefuck for faster shell startup
fuck() {
  unset -f fuck
  eval $(thefuck --alias)
  fuck "$@"
}

# setup fzf key bindings and fuzzy completion
eval "$(fzf --zsh)"

# ---- Zoxide (better cd) ----
eval "$(zoxide init zsh)"
alias cd="z"

# -- Use fd instead of fzf --

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"
export CHROME_BIN="/mnt/c/Program Files/Google/Chrome/Application/chrome.exe"

show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo ${}'"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
  esac
}

# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}

# # Go installation directory
# export GOROOT=/usr/local/go
#
# # GOPATH workspace
# export GOPATH=$HOME/go
#
# # Update PATH
export PATH=$PATH:$GOROOT/bin
export PATH=$PATH:$GOPATH/bin
#
#
# export PATH=$PATH:/home/dogukanaydogdu/.bin
# export PATH="$HOME/.local/bin:$PATH"
# export PATH=$PATH:/home/dogukanaydogdu/go/bin
#

# --- Go setup (no hardcoded GOROOT) ---
export GOPATH="$HOME/go"

# Prefer Go 1.23.9 toolchain installed via `go1.23.9 download`
export PATH="$HOME/sdk/go1.23.9/bin:$GOPATH/bin:$HOME/.local/bin:$HOME/.bin:$PATH"

# Let the Go tool auto-select the repo's requested toolchain
export GOTOOLCHAIN=auto



export NVM_DIR="$HOME/.nvm"
# Lazy load nvm for faster shell startup
nvm() {
  unset -f nvm
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
  nvm "$@"
}


source ~/fzf-git.sh
source $ZSH/oh-my-zsh.sh

# ~/.zshrc
# eval "$(starship init zsh)"


# Claude Code Telemetry
[ -f "$HOME/.claude/env" ] && source "$HOME/.claude/env"

