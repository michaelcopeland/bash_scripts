#!/bin/bash

# Often times I found myself needing to update to a new version of PHP. This was a hassle as I also needed to update the extensions.
# I didn't want to copy and paste every single one anymore. So I made this script and now we're able to do it with ease.

# Function to execute command
run_cmd() {
    echo -e "\033[0;33mWill execute:\033[0m $@"
    while true; do
        echo -e "\033[0;33mDo you want to proceed? [Y/n]\033[0m"
        read -r confirmation
        case $confirmation in
            Y )
                eval $@
                echo -e "\033[0;32mCommand executed.\033[0m"
                break;;
            y )
                echo -e "\033[0;31mPlease use uppercase 'Y' to confirm.\033[0m";;
            n|* )
                echo -e "\033[0;31mCommand aborted.\033[0m"
                break;;
        esac
    done
}

# Show currently installed PHP versions
CURRENT_VERSIONS=$(dpkg -l | grep 'php' | grep -oP 'php[0-9]\.[0-9]+' | sort -u)
if [ -z "$CURRENT_VERSIONS" ]; then
    echo -e "\033[0;31mNo PHP versions currently installed.\033[0m"
else
    echo -e "\033[0;32mCurrently installed PHP versions:\033[0m"
    echo "$CURRENT_VERSIONS"
fi

# Fetch and display available PHP versions from the repository, excluding already installed versions
echo -e "\033[0;36mFetching available PHP versions...\033[0m"
AVAILABLE_VERSIONS=$(apt-cache search php | grep -oP 'php[0-9]\.[0-9]+' | sort -u | grep -vxF -f <(echo "$CURRENT_VERSIONS"))
if [ -z "$AVAILABLE_VERSIONS" ]; then
    echo -e "\033[0;31mNo new PHP versions available for installation.\033[0m"
    exit 0
else
    echo -e "\033[0;32mAvailable PHP versions for installation:\033[0m"
    echo "$AVAILABLE_VERSIONS" | nl
fi

# Prompt user to select PHP version
echo -e "\033[0;33mEnter the number for the desired PHP version to install (or press Enter to cancel):\033[0m"
read -r choice
if [ -z "$choice" ]; then
    echo -e "\033[0;31mInstallation cancelled.\033[0m"
    exit 0
fi
TARGET_PHP_VERSION=$(echo "$AVAILABLE_VERSIONS" | sed -n "${choice}p")

if [ -z "$TARGET_PHP_VERSION" ]; then
    echo -e "\033[0;31mInvalid selection.\033[0m"
    exit 1
fi

echo -e "\033[0;32mYou selected $TARGET_PHP_VERSION\033[0m"

# Detect installed PHP extensions for the current version
echo -e "\033[0;36mDetecting installed PHP extensions...\033[0m"
INSTALLED_EXTENSIONS=$(dpkg -l | grep 'php' | awk '{print $2}' | grep -oP "(?<=php[0-9]\.[0-9]-).+")

if [ -z "$INSTALLED_EXTENSIONS" ]; then
    echo -e "\033[0;31mNo PHP extensions detected for the current version.\033[0m"
else
    echo -e "\033[0;32mInstalled extensions:\033[0m"
    echo "$INSTALLED_EXTENSIONS"
fi

# Construct the command to install the selected PHP version and its extensions
CMD="sudo apt install $TARGET_PHP_VERSION"
for ext in $INSTALLED_EXTENSIONS; do
    CMD="$CMD ${TARGET_PHP_VERSION}-${ext}"
done

# Show the command to be executed
echo -e "\033[0;36mCommand to execute:\033[0m"
echo -e "\033[0;35m$CMD\033[0m"

# Prompt for confirmation and execute or abort
run_cmd "$CMD"
