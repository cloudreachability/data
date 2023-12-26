#!/bin/bash

# Check if an input file is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <input_file>"
    exit 1
fi

input_file=$1
base_name=$(basename "$input_file" .csv)
current_datetime=$(date +"%Y%m%d_%H%M%S")
output_file="${base_name}.updated_${current_datetime}.csv"

# Check if output file already exists, create a new file with a timestamp
if [ -e "$output_file" ]; then
    output_file="${base_name}.updated_${current_datetime}_$(date +"%N").csv"
fi

# Function to extract the domain from a URL
extract_domain() {
    local url=$1
    # Extract the domain using awk and regex
    echo "$url" | awk -F[/:] '{print $4}'
}

# Function to get the IP address using dig, filtering out non-IP lines
get_ip_address() {
    local domain=$1
    # Get the IP address, filter out non-IP lines
    dig +short "$domain" | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -n 1
}

# Process each line in the input file
while IFS=',' read -r url rest; do
    # Remove the trailing semicolon
    rest=${rest%;}

    # Extract domain from URL
    domain=$(extract_domain "$url")

    # Get the IP address of the domain
    ip_address=$(get_ip_address "$domain")

    # Check if the IP address was found and if it's reachable via ping
    if [ -z "$ip_address" ] || ! ping -c 2 "$ip_address" &> /dev/null; then
        ip_address="0"
    fi

    # Append the data and IP address to the line and write to the output file
    echo "${url},${rest},${ip_address};" >> "$output_file"
done < "$input_file"

echo "Updated file is saved as $output_file"
