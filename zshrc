export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
zstyle ':omz:update' mode auto      # update automatically without asking

# Automatically set up tmux sessions
if command -v tmux &> /dev/null; then
    # Check if tmux is already running
    if [ -z "$TMUX" ]; then
        # Function to create a session with two horizontal panes and selectively open NeoVim
        create_session_with_optional_nvim() {
            local session_name=$1
            local dir1=$2
            local dir2=$3
            local open_nvim_in_first_pane=$4

            # Create the session if it doesn't exist
            tmux has-session -t "$session_name" 2>/dev/null || {
                if [ "$open_nvim_in_first_pane" = true ]; then
                    # Start the first pane with NeoVim in the specified directory
                    tmux new-session -d -s "$session_name" "cd $dir1 && nvim"
                else
                    # Start the first pane as a regular shell in the specified directory
                    tmux new-session -d -s "$session_name" -c "$dir1"
                fi
                # Split the window into two horizontal panes with the second pane as a regular shell
                tmux split-window -v -t "$session_name" -c "$dir2"
            }
        }

        # Create sessions with NeoVim in the first pane only for setup and notes sessions
        create_session_with_optional_nvim setup "$HOME/dotfiles" "$HOME/dotfiles" true
        create_session_with_optional_nvim setup "/mnt/c/Users/doguk/iCloudDrive/iCloud~md~obsidian/dogukanaydogdu" "/mnt/c/Users/doguk/iCloudDrive/iCloud~md~obsidian/dogukanaydogdu" false
        create_session_with_optional_nvim main "$HOME" "$HOME" false
        create_session_with_optional_nvim ucd "$HOME" "$HOME" false

        # Attach to the main session
        tmux attach-session -t main
    fi
fi

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
plugins=(git)

source $ZSH/oh-my-zsh.sh

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
alias notes="cd /mnt/c/Users/doguk/iCloudDrive/iCloud~md~obsidian/dogukanaydogdu"
# alias vimo="nvim $(fzf)"
alias vim="nvim"
alias k="kubectl"
alias aws-login="aws sso --profile atrium login" 
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

eval $(thefuck --alias)

# setup fzf key bindings and fuzzy completion
eval "$(fzf --zsh)"

# ---- Zoxide (better cd) ----
eval "$(zoxide init zsh)"
alias cd="z"

# -- Use fd instead of fzf --

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

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

# Set GOROOT (Go installation location)
export GOROOT=/usr/local/go

# Set GOPATH (your Go workspace)
export GOPATH=$HOME/dogukanaydogdu/go

export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:$HOME/dogukanaydogdu/go/bin
export PATH=$PATH:/home/dogukanaydogdu/.bin
export PATH="$HOME/.local/bin:$PATH"


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


source ~/fzf-git.sh
source $ZSH/oh-my-zsh.sh

# ~/.zshrc
eval "$(starship init zsh)"
