#!/bin/sh

# Reads user input and shows default value if already set.
# $1: Message to be displayed to the user
# $2: Variable name in which the value should be stored
function user_input() {
  PLACEHOLDERQWERTY=
  if ! [[ -z ${!2+x} ]]; then
    PLACEHOLDERQWERTY="[${!2}] "
  fi

  read -p "$1 ${PLACEHOLDERQWERTY}" -r

  if ! [[ -z $REPLY ]]; then
    # printf -v "$2" '%s' $REPLY
    export "$2"="$REPLY"
  fi
}

# Use this to set the new config value, needs 2 parameters.
# $1: Config name/key
# $2: Config value, defaults to $key
# $3: Config file, defaults to CONFIG_FILE
function set_config() {
  key=$1
  value=$2
  file=$3

  if [[ -z ${2+x} ]]; then
    value="${!1}"
  fi

  if [[ $value == *" "* ]]; then
   value="\"${value}\""
  fi

  if [[ -z ${3+x} ]]; then
    file=$CONFIG_FILE
  fi

  # Initialise CONFIG_FILE if it's missing
  if [ ! -e "${file}" ] ; then
    touch $file
  fi

  # Initialise key if it's missing
  if ! grep -q "^${key}=" ${file}; then
    # insert a newline just in case the file does not end with one
    echo "${key}=" >> ${file}
  fi

  # Modify key value
  sed -i "" "s#^\($key\s*=\s*\).*\$#\1$value#" $file
}

add_dock_item() {
  if [[ -d "$1" ]]; then
    echo "adding $1"
    defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>$1</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
  fi
}
