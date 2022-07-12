#!/bin/sh

# Update mackup files
mackup -f backup

# Run user script if available
if [[ -f "$USERCONFIG/backup.sh" ]]; then
  echo " => Running user script"
  source "$USERCONFIG/backup.sh"
fi
