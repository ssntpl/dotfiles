# Reset the path variable.
# We are resetting the path variable as on reloading shell the PATH variable gets duplicate entries
path=''

# Default paths (Duplicates will be removed automatically)
path+=('/usr/local/bin')
path+=('/usr/local/sbin')
path+=('/usr/bin')
path+=('/usr/sbin')
path+=('/bin')
path+=('/sbin')
path+=('/Library/Apple/usr/bin')

# Node: Use project specific binaries before global ones
path+=('node_modules/.bin')
path+=("$HOME/.node/bin")

# Composer: Use project specific binaries before global ones
path+=('vendor/bin')
path+=("$HOME/.composer/vendor/bin")

# Flutter (Not required when flutter is installed through homebrew)
# path+=("$HOME/.flutter/bin")

# Homebrew: We prepend the homebrew path again so that they are first in PATH.
# eval $(...brew shellenv) executes only once, so we are manually setting the homebrew PATH.
path=('/opt/homebrew/bin' $path)
path=('/opt/homebrew/sbin' $path)

# Custom binaries: Prepend the custom binaries path.
path=("$DOTFILES/bin" $path)

# Make sure coreutils are loaded before system commands
path=("$(brew --prefix coreutils)/libexec/gnubin:$PATH" $path)

# Avoid explicit export with -x and leave only unique values in the variable with -U
typeset -TUx PATH path

# export to sub-processes (make it inherited by child processes)
export -U PATH

# Add brew path. This command is same as adding the following paths.
# export HOMEBREW_PREFIX="/opt/homebrew";
# export HOMEBREW_CELLAR="/opt/homebrew/Cellar";
# export HOMEBREW_REPOSITORY="/opt/homebrew";
# export PATH="/opt/homebrew/bin:/opt/homebrew/sbin${PATH+:$PATH}";
# export MANPATH="/opt/homebrew/share/man${MANPATH+:$MANPATH}:";
# export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}";
eval $(/opt/homebrew/bin/brew shellenv)


# Export other variables
export ANDROID_SDK_ROOT=$HOME/Library/Android/sdk
export XDEBUG_CONFIG="idekey=VSCODE"
export EDITOR='code'

# Export WORKING_DIRECTORIES
working_directories+=("$HOME/Developer")
