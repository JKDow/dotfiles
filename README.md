# dotfiles

## Dependencies
On the new ansible system all dependencies are installed automatically
- Lua for installation of Luarocks
- Luarocks for Plenary on nvim
- xclip, xsel for copy/paste functionality in nvim
- Nerd Font for icons (JetBrains Mono)

## installation
Run the bootstrap.sh file and it will handle everything
- Installing ansible and collections
- Running ansible playbook
    - Installing base packages
    - Setting up AUR packages (Arch)
    - Stowing dotfiles
    - Setting up tmux and shell (Zsh)
    - Installing and configuring hyprland GUI (Arch)

There is a legacy installer at setup/legacy_install
This is the old bash script that stows the packages without ansible

## Stow Targets
### alacritty

### bin

### hyprland

### nvim

### starship

### tmux

### wallust

### waybar

### waypaper

### wofi

### zsh

## Other Directories
### setup
