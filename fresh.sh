#!/bin/sh

echo "Setting up your Mac..."

# Check if Xcode Command Line Tools are installed
if ! xcode-select -p &>/dev/null; then
  echo "Xcode Command Line Tools not found. Installing..."
  xcode-select --install
else
  echo "Xcode Command Line Tools already installed."
fi

# Check for Oh My Zsh and install if we don't have it
if test ! $(which omz); then
  /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/HEAD/tools/install.sh)"
fi

# Check for Homebrew and install if we don't have it
if test ! $(which brew); then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> $HOME/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi


# Update Homebrew recipes
brew update

# Install all our dependencies with bundle (See Brewfile)
brew tap homebrew/bundle
brew bundle --file ./Brewfile

# Use Stow to symlink dotfiles
# -v: verbose
# --adopt: treat existing files in target as if they belong to stow (useful for first run if user has files)
# . : stow the current directory
echo "Stowing dotfiles..."
stow -v --adopt .


# Set default MySQL root password and auth type
# mysql -u root -e "ALTER USER root@localhost IDENTIFIED WITH mysql_native_password BY 'password'; FLUSH PRIVILEGES;"

# Create a projects directories
mkdir $HOME/code

# Clone Github repositories (if exists)
if [ -f ./clone.sh ]; then
  ./clone.sh
fi


# Set macOS preferences - we will run this last because this will reload the shell
source ./.macos
