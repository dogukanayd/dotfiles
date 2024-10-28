all: sync

sync:
	mkdir -p ~/.config/nvim
	mkdir -p ~/.tmux/

	# Remove existing files before creating new symlinks
	[ ! -f ~/.vimrc ] || rm -f ~/.vimrc
	ln -sf $(PWD)/vimrc ~/.vimrc

	[ ! -f ~/.config/nvim/init.lua ] || rm -f ~/.config/nvim/init.lua
	ln -sf $(PWD)/init.lua ~/.config/nvim/init.lua

	[ ! -f ~/.tmux.conf ] || rm -f ~/.tmux.conf
	ln -sf $(PWD)/tmux.conf ~/.tmux.conf

	[ ! -f ~/.gitconfig ] || rm -f ~/.gitconfig
	ln -sf $(PWD)/gitconfig ~/.gitconfig

	[ ! -f ~/.zshrc] || rm -f ~/.zshrc
	ln -sf $(PWD)/zshrc ~/.zshrc

	[ ! -f ~/.alacritty.toml] || rm -f ~/.alacritty.toml
	ln -sf $(PWD)/alacritty.toml ~/.alacritty.toml

clean:
	rm -f ~/.vimrc 
	rm -f ~/.config/nvim/init.lua
	rm -f ~/.tmux.conf
	rm -f ~/.gitconfig

.PHONY: all clean sync

