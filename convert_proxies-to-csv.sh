#!/bin/bash

# Check if both type and protocol are provided as arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <type> <protocol>"
    exit 1
fi

type=$1
protocol=$2

# Function to convert the input into the desired format
convert_input() {
    local input="$1"
    local converted="user_id,proxy_ip,port,type,protocol,username,password"
    while IFS= read -r line; do
        IFS=':' read -r ip port username password <<< "$line"
        converted+=$'\n"",'"$ip,$port,$type,$protocol,$username,$password"
    done <<< "$input"
    echo "$converted"
}

# Prompt the user to paste the input
echo "Please paste the input below and press Ctrl+D when finished:"
input=$(cat)

# Convert the input
converted_input=$(convert_input "$input")

# Export the converted input to a CSV file in the same directory
output_file="proxies.csv"
echo "$converted_input" > "$output_file"
echo "CSV file exported as $output_file in the current directory."
