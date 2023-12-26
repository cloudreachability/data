#!/bin/bash

# Check if an input file is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <input_file>"
    exit 1
fi

input_file=$1
base_name=$(basename "$input_file" .csv)

# Get current date and time for the filename
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

# Process each line in the input file
while IFS=',' read -r url rest; do
    # Remove the trailing semicolon
    rest=${rest%;}

    # Extract domain from URL
    domain=$(extract_domain "$url")

    # Get the IP address of the domain
    ip_address=$(dig +short "$domain" | head -n 1)

    # Check if the IP address was found
    if [ -z "$ip_address" ] || ! curl --head --silent --fail "$url" > /dev/null; then
        ip_address="0"
    fi

    # Append the data and IP address to the line and write to the output file
    echo "${url},${rest},${ip_address};" >> "$output_file"
done < "$input_file"

echo "Updated file is saved as $output_file"
