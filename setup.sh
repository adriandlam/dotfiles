#!/bin/bash

brew update
brew upgrade

brew install stow
brew install lazygit
brew install zoxide
brew install gh
brew install ghostty

# Create symlinks
# Run stow from the dotfiles directory, targeting home directory
stow --target="$HOME" .

# Setup zsh plugins
brew install pure
brew install zsh-autocomplete
brew install zsh-autosuggestions

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting
