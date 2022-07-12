# Shortcuts
alias copyssh="pbcopy < $HOME/.ssh/id_rsa.pub"
alias reloadshell="source $HOME/.zshrc"
alias flushdns="dscacheutil -flushcache && sudo killall -HUP mDNSResponder"
alias ll="/usr/local/opt/coreutils/libexec/gnubin/ls -AhlFo --color --group-directories-first"
alias xcode='xed'
alias lsperm="stat -f '%A %a %N' *"
alias nosleep="caffeinate -dimsu"
alias showhidden="defaults write com.apple.finder AppleShowAllFiles -bool TRUE && killall Finder"
alias hidehidden="defaults write com.apple.finder AppleShowAllFiles -bool FALSE && killall Finder"

# Directories
alias icloud='cd $HOME/Library/Mobile\ Documents/com~apple~CloudDocs'
alias dotfiles='cd "$DOTFILES"'
alias developer="cd $HOME/Developer"

# Laravel
alias pa="php artisan"
alias pat="php artisan tinker"
alias fresh="php artisan migrate:fresh --seed"

alias refresh="rm -rf vendor/ composer.lock && composer i && rm -rf node_modules/ package-lock.json && npm install"

# PHP
alias cfresh="rm -rf vendor/ composer.lock && composer i"
# alias composer="php -d memory_limit=-1 /usr/local/bin/composer"

# JS
alias nfresh="rm -rf node_modules/ package-lock.json && npm install"
alias watch="npm run watch"
