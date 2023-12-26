#!/bin/bash

# Check if an input file is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <input_file>"
    exit 1
fi

input_file="$1"

# Read each line from the file
while IFS= read -r line
do
    # Extract the URL (first entry) and the IP address (last entry after the comma) from each line
    url=$(echo "$line" | awk -F',' '{print $1}')
    ip_address=$(echo "$line" | awk -F',' '{print $NF}' | sed 's/;$//')

    # Run ping command with a timeout of 5 seconds and capture the output
    ping_output=$(ping -c 1 -W 5 "$ip_address" 2>&1)
    if [ $? -eq 0 ]; then
        # Extract the average ping time
        avg_latency=$(echo "$ping_output" | grep -o 'min/avg/max/stddev = [^/]\+/[^/]\+/[^/]\+/[^/]\+' | cut -d '/' -f 5)
        if [ -n "$avg_latency" ]; then
            echo "Ping to $url ($ip_address): Successful (Average Latency: $avg_latency)"
        else
            echo "Ping to $url ($ip_address): Successful (Average Latency information not available)"
        fi
    else
        echo "Ping to $url ($ip_address): Failed"
    fi
done < "$input_file"
