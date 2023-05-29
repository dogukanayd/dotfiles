all: sync

sync:
	mkdir -p ~/.config/nvim
	mkdir -p ~/.tmux/

	[ -f ~/.vimrc ] || ln -s $(PWD)/vimrc ~/.vimrc
	[ -f ~/.config/nvim/init.lua ] || ln -s $(PWD)/init.lua ~/.config/nvim/init.lua
	[ -f ~/.tmux.conf ] || ln -s $(PWD)/tmux.conf ~/.tmux.conf
	[ -f ~/.gitconfig ] || ln -s $(PWD)/gitconfig ~/.gitconfig

clean:
	rm -f ~/.vimrc 
	rm -f ~/.config/nvim/init.lua
	rm -f ~/.tmux.conf
	rm -f ~/.gitconfig

.PHONY: all clean sync 

