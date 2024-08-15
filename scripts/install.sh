#!/bin/sh

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.macos` has finished
while true; do sudo -n true; sleep 50; kill -0 "$$" || exit; done 2>/dev/null &

# launch process to prevent sleep and move it to the background
caffeinate -dimsu &
# save the process ID
CAFFEINATE_PID=$!

# Uninstall mackup configurations if already present for old user
if [[ -d "$USERCONFIG/mackup" ]]; then
  echo " => Uninstalling mackup configurations"
  mackup -f uninstall
fi

user_input "Please enter your full name (eg. John Doe):" "NAME"
user_input "Please enter your official email id (eg. john.doe@apple.com):" "EMAIL"
user_input "Please enter your employee id (eg. 10001):" "EMPID"

USERCONFIG="$DOTFILES/users/$EMPID"

set_config "NAME"
set_config "EMAIL"
set_config "EMPID"
set_config "DOTFILES"
set_config "USERCONFIG"

# Check for Homebrew and install if we don't have it
if test ! $(which brew); then
  echo " => Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add brew to path in current terminal session. New sessions will already have brew in path.
  eval $(/opt/homebrew/bin/brew shellenv)
fi

# Check for Oh My Zsh and install if we don't have it
if test ! $(which omz); then
  echo " => Installing Oh My Zsh"
  RUNZSH=no # The installer will not run zsh after the install
  /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/HEAD/tools/install.sh)" "" --unattended
fi

# Install rosetta on Apple Silicon
if [[ $(uname -p) == 'arm' ]]; then
  softwareupdate --install-rosetta --agree-to-license
fi

# Update Homebrew recipes
echo " => Updating Homebrew"
brew update
rm -rf "$HOME/.Brewfile"
cp "$DOTFILES/config/Brewfile.global" "$HOME/.Brewfile"
if [[ -f "$USERCONFIG/Brewfile" ]]; then
  cat "$USERCONFIG/Brewfile" >> "$HOME/.Brewfile"
fi

# Confirm user to install xcode
if read -p "Do you want to install xcode? [Y/n] " -n 1 -r INSTALL_XCODE && echo && ([[ $INSTALL_XCODE =~ ^[Yy]$ ]] || [[ -z $INSTALL_XCODE ]]); then
  # Add cocoapods
  echo "brew 'cocoapods'" >> "$HOME/.Brewfile"

  # We must insert xcode at the end because any further brew packages will fail until we accept the license
  echo "mas 'Xcode', id: 497799835" >> "$HOME/.Brewfile"
fi

# Install all our dependencies with bundle (See Brewfile)
echo " => Installing brew bundles"
brew tap homebrew/bundle
brew bundle -q --file="$HOME/.Brewfile"

if [[ $INSTALL_XCODE =~ ^[Yy]$ ]] || [[ -z $INSTALL_XCODE ]]; then
  sudo xcodebuild -license accept

  # Add iOS & Watch Simulator to Launchpad
  sudo ln -sf "/Applications/Xcode.app/Contents/Developer/Applications/Simulator.app" "/Applications/Simulator.app"
  sudo ln -sf "/Applications/Xcode.app/Contents/Developer/Applications/Simulator (Watch).app" "/Applications/Simulator (Watch).app"
fi

# Start and set to auto-start MySQL
brew services restart mysql

# Start and set to auto-start mailpit
brew services restart mailpit

# Set default MySQL root password and auth type
# echo " => Setting root mysql password to 'password'"
# mysql -u root -e "ALTER USER root@localhost IDENTIFIED WITH mysql_native_password BY 'password'; FLUSH PRIVILEGES;"

# Install PHP extensions with PECL
# printf "\n" | pecl install imagick memcached redis swoole xdebug

# Install global Composer packages
echo " => Installing composer packages"
composer global require laravel/installer laravel/valet #laravel/vapor-cli laravel/forge-cli

# Install Laravel Valet
echo " => Installing valet"
$HOME/.composer/vendor/bin/valet install

# Add valet to sudoer
sudo $HOME/.composer/vendor/bin/valet trust

# Removes .zshrc from $HOME (if it exists) and symlinks the .zshrc file from the .dotfiles
echo " => Copying ZSH config files"
rm -rf $HOME/.zshrc
rm -rf $HOME/.zprofile
rm -rf $HOME/.zsh_config
cp "$DOTFILES/config/.zshrc" $HOME/.zshrc
cp "$DOTFILES/config/.zprofile" $HOME/.zprofile
cp -R "$DOTFILES/config/.zsh_config" $HOME/.zsh_config

# Configuring git
echo " => Configuring git"
rm -rf $HOME/.gitconfig
cp "$DOTFILES/config/.gitconfig" $HOME/.gitconfig
git config --global user.name "$NAME"
git config --global user.email "$EMAIL"

# Symlinking the standards files
echo " => Symlinking .gitignore_global, .editorconfig, .php-cs-fixer.php"
rm -rf $HOME/.gitignore_global
rm -rf $HOME/.editorconfig
rm -rf $HOME/.php-cs-fixer.php
ln -s "$DOTFILES/config/.gitignore_global" $HOME/.gitignore_global
ln -s "$DOTFILES/config/.editorconfig" $HOME/.editorconfig
ln -s "$DOTFILES/config/.php-cs-fixer.php" $HOME/.php-cs-fixer.php

# Copying phpMyAdmin config file
echo " => Configuring phpMyAdmin (access url: http://phpmyadmin.test)"
rm -rf $(brew --prefix)/etc/phpmyadmin.config.inc.php
cp "$DOTFILES/config/phpmyadmin.config.inc.php" $(brew --prefix)/etc/phpmyadmin.config.inc.php
cd $(brew --prefix)/share/phpmyadmin/
valet link
cd "$DOTFILES"

# Proxy mailpit.test to mailpit service on port 8025
echo " => Configuring mailpit (access url: http://mailpit.test)"
valet proxy mailpit http://127.0.0.1:8025

# Configuring mackup files
echo " => Configuring mackup files"
rm -rf $HOME/.mackup.cfg
rm -rf $HOME/.mackup
cp "$DOTFILES/config/.mackup.cfg" $HOME/.mackup.cfg
cp -R "$DOTFILES/config/.mackup" $HOME/.mackup
if [[ $DOTFILES == *"com~apple~CloudDocs"* ]]; then
  set_config "engine" "icloud" "$HOME/.mackup.cfg"
  set_config "directory" "${USERCONFIG#*CloudDocs/}/mackup" "$HOME/.mackup.cfg"
else
  user_input "Please enter mackup engine (eg. icloud):" "mackup_engine"
  user_input "Please enter mackup directory (eg. mackup):" "mackup_dir"
  set_config "engine" "$mackup_engine" "$HOME/.mackup.cfg"
  set_config "directory" "$mackup_dir" "$HOME/.mackup.cfg"
fi

# Change the localhost page to contain some basic information
sudo rm -rf /Library/WebServer/Documents/index.html
sudo rm -rf /Library/WebServer/Documents/index.html.en
echo "The system is assigned to <br/><br/>$NAME <br/>$EMAIL <br/>$EMPID" | sudo tee -a /Library/WebServer/Documents/index.html > /dev/null

# Set macOS preferences
if [[ -f "$DOTFILES/scripts/macos.sh" ]]; then # && read -p "Do you want to reset macOS preferences? [Y/n] " -n 1 -r && echo && ([[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]); then
  echo " => Configuring system preferences"
  source "$DOTFILES/scripts/macos.sh"
fi

# Run user script if available
if [[ -f "$USERCONFIG/install.sh" ]]; then
  echo " => Running user script"
  source "$USERCONFIG/install.sh"
fi

# Restore Mackup settings
if [[ -d "$USERCONFIG/mackup" ]]; then
  echo " => Restoring configurations managed through mackup"
  mackup -f restore
fi

# Backup system
if [[ -f "$DOTFILES/scripts/backup.sh" ]]; then
  echo " => Backing up your Mac"
  source "$DOTFILES/scripts/backup.sh"
fi

# kill caffeinate so the computer can sleep if it wants to
kill $CAFFEINATE_PID

echo
echo "System setup is complete."
echo
echo "We will now close all the affected applications including this terminal "
echo "session. Please save all your work before continuing to the next step. "
echo "Note that some of these changes require a logout/restart to take effect."
echo
echo
echo "The system will restart now."
read -p "Press Enter key to continue... " -n 1 -r
echo

# Restart is required to apply changes that require logout login
sudo shutdown -r now

########################################################################################################
# Kill affected applications - Always do it at the end of the script, as this will kill the script too #
########################################################################################################

for app in "Activity Monitor" \
    "Address Book" \
    "Calendar" \
    "cfprefsd" \
    "Contacts" \
    "Dock" \
    "Finder" \
    "Google Chrome Canary" \
    "Google Chrome" \
    "Mail" \
    "Messages" \
    "Opera" \
    "Photos" \
    "Safari" \
    "SizeUp" \
    "Spectacle" \
    "SystemUIServer" \
    "Terminal" \
    "Transmission" \
    "Tweetbot" \
    "Twitter" \
    "iCal"; do
    killall "${app}" &> /dev/null
done
