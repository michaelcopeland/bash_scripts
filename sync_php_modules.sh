#!/bin/bash

# Define colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Function to display a colored message
color_echo() {
    color="$1"
    message="$2"
    echo -e "${color}${message}${NC}"
}

# Function to list installed PHP versions
list_php_versions() {
    php_versions=($(ls /etc/php/))
    version_choices=()
    for version in "${php_versions[@]}"; do
        version_choices+=("$version" "" off)
    done

    selected_versions=$(whiptail --title "Select PHP Versions" --separate-output --checklist "Select PHP versions for extension synchronization:" 20 40 10 "${version_choices[@]}" 3>&1 1>&2 2>&3)

    if [ $? -eq 0 ]; then
        echo "Selected PHP Versions: $selected_versions"
        IFS="," read -ra selected_versions <<< "$selected_versions"
    else
        color_echo $RED "No PHP versions selected. Exiting."
        exit 1
    fi
}

# Function to sync extensions from source version to selected versions
sync_extensions() {
    source_version="$1"
    for version in "${selected_versions[@]}"; do
        if [ "$version" != "$source_version" ]; then
            extensions=($(php$source_version -m))
            for extension in "${extensions[@]}"; do
                sudo apt-get install -y php$version-$extension
                color_echo $GREEN "Installed $extension for PHP $version"
            done
        fi
    done
}

# Main script
list_php_versions

if [ "${#selected_versions[@]}" -eq 0 ]; then
    color_echo $RED "No PHP versions selected. Exiting."
    exit 1
fi

source_version=$(whiptail --title "Select PHP Source Version" --menu "Select the source PHP version for extension synchronization:" 20 40 10 "${selected_versions[@]}" 3>&1 1>&2 2>&3)

if [ $? -eq 0 ]; then
    color_echo $YELLOW "Synchronizing extensions from PHP $source_version to the following PHP versions: ${selected_versions[@]}"
    read -p "Continue? (Capital Y/N): " confirm

    if [ "$confirm" == "Y" ]; then
        sync_extensions $source_version
        color_echo $GREEN "Extensions synchronized successfully."
    else
        color_echo $RED "Sync canceled."
    fi
else
    color_echo $RED "No PHP source version selected. Exiting."
fi
