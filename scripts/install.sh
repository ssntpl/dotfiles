#!/bin/sh

# Uninstall mackup configurations if already present for old user
if [[ -d "$USERCONFIG/mackup" ]]; then
  echo " => Uninstalling mackup configurations"
  mackup -f uninstall
fi

user_input "Please enter your full name (eg. John Doe):" "NAME"
user_input "Please enter your official email id (eg. john.doe@apple.com):" "EMAIL"
user_input "Please enter your employee id (eg. 100022):" "EMPID"

USERCONFIG="$DOTFILES/users/$EMPID"

set_config "NAME"
set_config "EMAIL"
set_config "EMPID"
set_config "DOTFILES"
set_config "USERCONFIG"

# Check for Oh My Zsh and install if we don't have it
if test ! $(which zsh); then
echo " => Installing Oh My Zsh"
  /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/HEAD/tools/install.sh)"
fi

# Check for Homebrew and install if we don't have it
if test ! $(which brew); then
  echo " => Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Update Homebrew recipes
echo " => Updating Homebrew"
brew update

# Install all our dependencies with bundle (See Brewfile)
echo " => Installing brew bundles"
rm -rf "$DOTFILES/Brewfile"
cp "$DOTFILES/Brewfile.global" "$DOTFILES/Brewfile"
if [[ -f "$USERCONFIG/Brewfile" ]]; then
  cat "$USERCONFIG/Brewfile" >> "$DOTFILES/Brewfile"
fi
brew tap homebrew/bundle
brew bundle -q

# Set default MySQL root password and auth type
# echo " => Setting root mysql password to 'password'"
# mysql -u root -e "ALTER USER root@localhost IDENTIFIED WITH mysql_native_password BY 'password'; FLUSH PRIVILEGES;"

# Install PHP extensions with PECL
printf "\n" | pecl install imagick memcached redis swoole xdebug

# Install global Composer packages
echo " => Installing composer packages"
composer global require laravel/installer laravel/valet laravel/vapor-cli laravel/forge-cli

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

echo
echo "User setup is complete."
echo
echo "We will now configure the macOS preferences. All the applications"
echo "will be closed including this terminal session. Please save your"
echo "work before continuing to the next step."
echo

# Set macOS preferences - we will run this last because this will reload the shell
if [[ -f "$DOTFILES/scripts/macos.sh" ]] && read -p "Do you want to reset macOS preferences? [Y/n] " -n 1 -r && echo && ([[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]); then
  echo " => Configuring system preferences"
  source "$DOTFILES/scripts/macos.sh"
fi
