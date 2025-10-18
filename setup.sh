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
brew install zsh-autocomplete
brew install zsh-autosuggestions


