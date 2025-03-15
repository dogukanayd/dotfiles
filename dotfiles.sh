#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

# Define source directory
dotfiles_dir="$HOME/dotfiles"

# Configuration files mapping
declare -A config_files=(
    ["vim"]="vimrc:.vimrc"
    ["nvim"]="init.lua:.config/nvim/init.lua"
    ["glow"]="glow.yml:.config/glow/glow.yml"
    ["tmux"]="tmux.conf:.tmux.conf"
    ["git"]="gitconfig:.gitconfig"
    ["zsh"]="zshrc:.zshrc"
    ["alacritty"]="alacritty.toml:.alacritty.toml"
)

# Function to create directory for a target file
create_directory() {
    local target_dir=$(dirname "$1")
    if [ ! -d "$target_dir" ]; then
        mkdir -p "$target_dir"
        echo "Created directory: $target_dir"
    fi
}

# Function to create symlink with overwrite
create_symlink() {
    local source_file="$dotfiles_dir/$1"
    local target_file="$HOME/$2"
    
    # Ensure the target directory exists
    create_directory "$target_file"
    
    if [ -f "$target_file" ] || [ -L "$target_file" ]; then
        rm -f "$target_file"
    fi
    ln -sf "$source_file" "$target_file"
    echo "Linked: $source_file -> $target_file"
}

# Function to install a specific component
install_component() {
    local component=$1
    
    if [[ -z "${config_files[$component]}" ]]; then
        echo "Unknown component: $component"
        echo "Available components: ${!config_files[@]}"
        return 1
    fi
    
    echo "Installing $component configuration..."
    IFS=':' read -r source_path target_path <<< "${config_files[$component]}"
    create_symlink "$source_path" "$target_path"
}

# Function to install all components
install_all() {
    echo "Setting up all components..."
    for component in "${!config_files[@]}"; do
        install_component "$component"
    done
    echo "Setup completed successfully!"
}

# Function to clean configuration files
clean() {
    echo "Cleaning up configuration files..."
    
    for mapping in "${config_files[@]}"; do
        IFS=':' read -r _ target_path <<< "$mapping"
        local full_path="$HOME/$target_path"
        
        if [ -f "$full_path" ] || [ -L "$full_path" ]; then
            rm -f "$full_path"
            echo "Removed: $full_path"
        fi
    done
    
    echo "Clean up completed."
}

# Function to display usage information
show_usage() {
    echo "Usage: ./dotfiles.sh [command] [components...]"
    echo ""
    echo "Commands:"
    echo "  install  - Install specified components (default if no command provided)"
    echo "  clean    - Remove all configuration files"
    echo "  list     - List available components"
    echo "  help     - Show this help message"
    echo ""
    echo "Components: ${!config_files[@]}"
    echo ""
    echo "Examples:"
    echo "  ./dotfiles.sh                  - Install all components"
    echo "  ./dotfiles.sh install vim tmux - Install only vim and tmux"
    echo "  ./dotfiles.sh clean            - Remove all configuration files"
}

# Main script execution
command=${1:-"install"}
shift 2>/dev/null || true  # Shift to components, ignore error if no args

case "$command" in
    "install")
        if [ $# -eq 0 ]; then
            install_all
        else
            for component in "$@"; do
                install_component "$component"
            done
        fi
        ;;
    "clean")
        clean
        ;;
    "list")
        echo "Available components:"
        for component in "${!config_files[@]}"; do
            echo "  - $component"
        done
        ;;
    "help")
        show_usage
        ;;
    *)
        if [ -z "$command" ]; then
            install_all
        else
            # Treat the first argument as a component if it's not a known command
            install_component "$command"
            # Install any additional components specified
            for component in "$@"; do
                install_component "$component"
            done
        fi
        ;;
esac

exit 0
