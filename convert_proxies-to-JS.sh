#!/bin/bash

# Prompt the user to paste the input
echo "Please paste the input below and press Ctrl+D when finished:"
input=$(cat)

# Function to convert the input into the desired format
convert_input() {
    local input="$1"
    local converted=""
    while IFS= read -r line; do
        IFS=':' read -r ip port username password <<< "$line"
        converted+="{ server: 'http://$ip:$port', username: '$username', password: '$password' },"
        converted+=$'\n'
    done <<< "$input"
    converted="${converted%,}"  # Remove the trailing comma
    echo "$converted"
}

# Convert the input
converted_input=$(convert_input "$input")

# Print the converted input
echo "Converted output:"
echo "$converted_input"
