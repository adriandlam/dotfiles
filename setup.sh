#!/bin/bash

# Install Stow
brew install stow

# Create symlinks
# Run stow from the dotfiles directory, targeting home directory
stow --target="$HOME" .

