# dotfiles

This repo contains my shared config files for different systems as well as a script to manage it all

## Stow Manager
The stow manager is a script that tracks files to stow and automatically performs the actions

Inside stow_manager is a stow-config.toml file where the tracked packages are listed

Running `stowman.sh stow` or `stowman.sh unstow` will perform thoes actions on thoes packages

## Packages
- .config/nvim
- .config/tmux
- .local/bin
- .zshrc

## Dependencies
- Lua for installation of Luarocks
- Luarocks for Plenary on nvim
- xclip, xsel for copy/paste functionality in nvim
- Nerd Font for icons (JetBrains Mono)
