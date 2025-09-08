#!/bin/bash

# Function to delete a file or directory safely
delete() {
    if [ -e "$1" ]; then
        echo "Deleting: $1"
        rm -rf "$1"
    else
        echo "Not found: $1"
    fi
}

echo "Starting removal of Autotune 11 and associated files..."

# Autotune application directory
delete "/Applications/Antares Auto-Tune 11.app"

# User-specific files
delete "$HOME/Library/Application Support/Antares"
delete "$HOME/Library/Preferences/com.antares.AutoTune11.plist"
delete "$HOME/Library/Caches/com.antares.AutoTune11"

# Logs and other related files
delete "/Library/Logs/Antares"
delete "/Library/Caches/com.antares.AutoTune11"

echo "Removal process completed."


