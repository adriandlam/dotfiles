#!/bin/bash

set -e  # Exit on error

# Update Homebrew
echo "📦 Updating Homebrew..."
brew update
brew upgrade

# Install packages
echo "📦 Installing packages..."
brew install stow
brew install lazygit
brew install zoxide
brew install gh
brew install ghostty
brew install pnpm

# Create symlinks
# Run stow from the dotfiles directory, targeting home directory
stow --target="$HOME" .

# Install zsh enhancements
echo "🐚 Installing zsh plugins..."
brew install pure
brew install zsh-autosuggestions
brew install zsh-syntax-highlighting

if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "📝 Installing oh-my-zsh plugins..."

    if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions \
            ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    fi

    if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting" ]; then
        git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git \
            ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting
    fi
else
    echo "⚠️  oh-my-zsh not found, skipping plugin installation"
fi


# Create symlinks with stow
echo "🔗 Creating symlinks..."
stow --target="$HOME" --restow .

# Initialize git submodules (superpowers, etc.)
echo "📦 Initializing git submodules..."
git submodule update --init --recursive

# Set up opencode plugins + skills symlinks
echo "🔗 Setting up opencode plugins and skills..."
mkdir -p "$HOME/.config/opencode/plugins"
ln -sf "$HOME/.config/opencode/superpowers/.opencode/plugins/superpowers.js" \
       "$HOME/.config/opencode/plugins/superpowers.js"
mkdir -p "$HOME/.config/opencode/skills"
ln -sf "$HOME/.config/opencode/superpowers/skills" \
       "$HOME/.config/opencode/skills/superpowers"

# Apply macOS defaults
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "🍎 Applying macOS defaults..."
    bash "$(dirname "$0")/macos-defaults.sh"
fi

echo "✅ Installation complete!"
