#!/bin/sh

echo
echo "###############################"
echo "#                _         _  #"
echo "#  ___ ___ _ __ | |_ _ __ | | #"
echo "# / __/ __| '_ \| __| '_ \| | #"
echo "# \__ \__ \ | | | |_| |_) | | #"
echo "# |___/___/_| |_|\__| .__/|_| #"
echo "#                   |_|       #"
echo "#                             #"
echo "###############################"
echo
echo "Setting up your Mac..."
echo

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.macos` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

ICLOUD=$HOME/Library/Mobile\ Documents/com~apple~CloudDocs
CONFIG_FILE=$HOME/.ssntpl

# Fetch the user configuration, if present.
if [[ -f "$CONFIG_FILE" ]]; then
  source "$CONFIG_FILE"
fi

# We are setting DOTFILES after sourcing the CONFIG_FILE as it may contain outdated location
DOTFILES=$(dirname "$(realpath $0)")

# Source the functions required for this script
source "$DOTFILES/scripts/functions.sh"

# Disable "Optimize Mac Storage" option to prevent offloading of DOTFILES from local storage
# TODO:  → System Preferences → Apple ID → Click on iCloud in the sidebar → uncheck Optimise Mac Storage

echo "Downloading backup files from icloud"
find "$DOTFILES" -type f -name "*.icloud" -exec brctl download {} \;
# TODO: wait for icloud files to download

# Setup fresh system
if ! ( [[ -f "$HOME/.ssntpl" ]] && read -p "Do you want to reset your Mac? [y/N] " -n 1 -r && echo && [[ ! $REPLY =~ ^[Yy]$ ]] ); then
  echo " => Configuring your Mac"
  source "$DOTFILES/scripts/install.sh"
fi

# Backup system
if [[ -f "$DOTFILES/scripts/backup.sh" ]] && read -p "Do you want to backup your Mac? [Y/n] " -n 1 -r && echo && ([[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]); then
  echo " => Backing up your Mac"
  source "$DOTFILES/scripts/backup.sh"
fi
