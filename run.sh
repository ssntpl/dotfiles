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

ICLOUD=$HOME/Library/Mobile\ Documents/com~apple~CloudDocs
CONFIG_FILE=$HOME/.ssntpl

# Fetch the user configuration, if present.
if [[ -f "$CONFIG_FILE" ]]; then
  source "$CONFIG_FILE"
fi

# We are setting DOTFILES after sourcing the CONFIG_FILE as it may contain outdated location
DOTFILES="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# Download all the dotfiles before proceeding to the next step
ICLOUD_DOTFILES_TOTAL_COUNT=$(find "$DOTFILES" -type f -name "*.icloud" | wc -l)
ICLOUD_DOTFILES_COUNT=$ICLOUD_DOTFILES_TOTAL_COUNT
while (( $ICLOUD_DOTFILES_COUNT )); do
  echo " => Downloading $ICLOUD_DOTFILES_COUNT of $ICLOUD_DOTFILES_TOTAL_COUNT backup files from icloud..."
  find "$DOTFILES" -type f -name "*.icloud" -exec brctl download {} \;
  sleep 10
  ICLOUD_DOTFILES_COUNT=$(find "$DOTFILES" -type f -name "*.icloud" | wc -l)
done

# Source the functions required for this script
source "$DOTFILES/scripts/functions.sh"

# Setup fresh system
if ! ( [[ -f "$HOME/.ssntpl" ]] && read -p "Do you want to reset your Mac? [y/N] " -n 1 -r && echo && [[ ! $REPLY =~ ^[Yy]$ ]] ); then
  echo " => Configuring your Mac"
  source "$DOTFILES/scripts/install.sh"
fi

# Backup system
if [[ -f "$DOTFILES/scripts/backup.sh" ]]; then # && read -p "Do you want to backup your Mac? [Y/n] " -n 1 -r && echo && ([[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]); then
  echo " => Backing up your Mac"
  source "$DOTFILES/scripts/backup.sh"
fi
