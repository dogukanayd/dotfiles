all: sync

sync:
	mkdir -p ~/.config/alacritty
	mkdir -p ~/.config/fish
	mkdir -p ~/.config/nvim
	mkdir -p ~/.tmux/

clean:
	rm -f ~/.vimrc 
	rm -f ~/.config/nvim/init.lua
	rm -f ~/.config/alacritty/color.yml
	rm -f ~/.config/fish/config.fish
	rm -f ~/.config/fish/functions/
	rm -f ~/.tmux.conf
	rm -f ~/.tigrc
	rm -f ~/.gitconfig
	rm -f ~/.agignore
	rm -f ~/.agignore

.PHONY: all clean sync 

