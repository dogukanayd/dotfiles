export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
zstyle ':omz:update' mode auto      # update automatically without asking


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
alias docker-clean="docker system prune && docker container prune && docker network prune && docker image prune && docker volume prune"
alias cat="bat"

# Functions
weather () {
  city=${1:-5}
  curl https://wttr.in/$city
}

eval $(thefuck --alias)

export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:$HOME/go/bin
export PATH=$PATH:/home/dogukanaydogdu/.bin
source $ZSH/oh-my-zsh.sh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
