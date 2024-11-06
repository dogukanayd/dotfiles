all: sync

sync:
	mkdir -p ~/.config/nvim
	mkdir -p ~/.tmux/
	# Remove existing files before creating new symlinks
	[ ! -f ~/.vimrc ] || rm -f ~/.vimrc
	ln -sf /home/dogukanaydogdu/dotfiles/vimrc ~/.vimrc
	[ ! -f ~/.config/nvim/init.lua ] || rm -f ~/.config/nvim/init.lua
	ln -sf /home/dogukanaydogdu/dotfiles/init.lua ~/.config/nvim/init.lua
	# config for the glow
	[ ! -f ~/.config/glow/glow.yml ] || rm -f ~/.config/glow/glow.yml
	ln -sf /home/dogukanaydogdu/dotfiles/glow.yml ~/.config/glow/glow.yml
	[ ! -f ~/.tmux.conf ] || rm -f ~/.tmux.conf
	ln -sf /home/dogukanaydogdu/dotfiles/tmux.conf ~/.tmux.conf
	[ ! -f ~/.gitconfig ] || rm -f ~/.gitconfig
	ln -sf /home/dogukanaydogdu/dotfiles/gitconfig ~/.gitconfig
	[ ! -f ~/.zshrc ] || rm -f ~/.zshrc  # Fixed spacing here
	ln -sf /home/dogukanaydogdu/dotfiles/zshrc ~/.zshrc
	[ ! -f ~/.alacritty.toml ] || rm -f ~/.alacritty.toml  # Fixed spacing here
	ln -sf /home/dogukanaydogdu/dotfiles/alacritty.toml ~/.alacritty.toml
clean:
	rm -f ~/.vimrc 
	rm -f ~/.config/nvim/init.lua
	rm -f ~/.tmux.conf
	rm -f ~/.gitconfig

.PHONY: all clean sync

