

## Introduction

This repository is created to help the system admin to automatically setup macOS for different developers/users in the company. It takes the effort out of installing everything manually. Everything needed to install the preferred setup of macOS is detailed in this readme. 


## A Fresh macOS Setup

These instructions are for when you are using company provided dotfiles. If you want to get started with your own dotfiles you can fork this repository and make the required modifications.

### Before you re-install

First, go through the checklist below to make sure you didn't forget anything before you wipe your hard drive.

- Commit and push any changes/branches to your git repositories in `~/Developer` folder.
- Save all important documents from non-iCloud directories to a safe location.
- Save all of your work from apps which aren't synced through iCloud.
- Check and export important data from your local database.


### Installing macOS cleanly

After going to our checklist above and making sure you backed everything up, we're going to cleanly install macOS with the latest release. Follow [this article](https://support.apple.com/en-in/guide/mac-help/mh27903/mac) to erase and re-install the latest macOS version.

### Setting up your Mac

If you did all of the above you may now follow these install instructions to setup a new Mac.

1. Update macOS to the latest version with the App Store

2. Login with company apple id or your personal apple id.

3. You can skip this step if you have logged in with the company provided apple id.
   Clone this repo to `.dotfiles` folder in iCloud (or dropbox) with:

    ```zsh
    git clone git@github.com:ssntpl/dotfiles.git "~/Library/Mobile Documents/com~apple~CloudDocs/.dotfiles"
    ```

4. Run the installation with:

    ```zsh
    cd ~/Library/Mobile Documents/com~apple~CloudDocs/.dotfiles
    ./run.sh
    ```

5. Restart your computer to finalize the process

Your Mac is now ready to use!

> 💡 If you are using iCloud, then remember to disable "Optimize Mac Storage" option to prevent offloading of DOTFILES from the local storage.
( → System Preferences → Apple ID → Click on iCloud in the sidebar → uncheck Optimise Mac Storage)


