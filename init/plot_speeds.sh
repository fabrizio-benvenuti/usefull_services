#!/bin/bash
validate_line() {
    local line="$1"
    
    # Check if key phrases are present
    if [[ ! $line =~ "Download:" || ! $line =~ "Upload:" ]]; then
        echo "download upload error"
	return 1
    fi
    
    # Check for consistency of format
    if [[ ! $line =~ ^Download:\ [0-9]+\.[0-9]+\ Mbit/s\ Upload:\ [0-9]+\.[0-9]+\ Mbit/s\ [0-9]{4}-[0-9]{2}-[0-9]{2}\ [0-9]{2}:[0-9]{2}:[0-9]{2}$ ]]; then
        echo "format error"
	return 1
    fi
    
    # Extract and validate speeds
    local speeds
    speeds=$(echo "$line" | grep -oP '\d+\.\d+')
    if [[ $(wc -w <<< "$speeds") -ne 2 ]]; then
        echo "validate speed error"
	return 1
    fi
    
    # Extract and validate timestamp
    local timestamp
    timestamp=$(echo "$line" | grep -oP '\d{4}-\d{2}-\d{2}\ \d{2}:\d{2}:\d{2}')
    if [[ -z $timestamp ]]; then
	echo "validate timestamp"
        return 1
    fi
    
    return 0
}

# Define input and output file paths
inp_file="/home/server2/speedtest.txt"
opt_file="/tmp/speedtest_filtered.txt"
cat $inp_file
# Get the current time in seconds since epoch
current_time=$(date +%s)
# Calculate the time 12 hours ago in seconds
twelve_hours_ago=$((current_time - 43200))
# Read the input file line by line
while IFS= read -r line; do
    if validate_line "$line"; then
    	# Extract download speed, upload speed, and timestamp from the line
    	download_speed=$(echo "$line" | awk '{print $2}')
    	upload_speed=$(echo "$line" | awk '{print $5}')
    	timestamp=$(echo "$line" | awk '{print $7 " " $8}')

    	# Convert the timestamp to seconds since epoch
    	timestamp_seconds=$(date -d "$timestamp" +%s)

    	# Check if the measurement was done later than 12 hours ago
    	if [ "$timestamp_seconds" -gt "$twelve_hours_ago" ]; then
        	# Print the measurement if it's recent
        	echo "$download_speed $upload_speed $timestamp"
    	fi
    fi
done < "$inp_file" > "$opt_file"
echo "///////////////"
cat $opt_file
# Extract download and upload speeds from the filtered data
awk '{print $1}' /tmp/speedtest_filtered.txt > /tmp/download_speeds.txt
awk '{print $2}' /tmp/speedtest_filtered.txt > /tmp/upload_speeds.txt
echo "$(grep -c  '' /tmp/upload_speeds.txt)"
echo "$(grep -c  '' /tmp/download_speeds.txt)"
# Plot the speeds histogram
gnuplot -persist <<-EOFMarker
    set terminal png size 800,600
    set output '/tmp/speeds_histogram.png'
    set title "Download and Upload Speeds Histogram  (from 12 hours ago)"
    set xlabel "Speed (Mbit/s)"
    set ylabel "Frequency"
    set xtics 10

    # For Download speeds
    download_binwidth=20
    download_bin(x,width)=width*floor(x/width) + download_binwidth/2.0

    # For Upload speeds
    upload_binwidth=5
    upload_bin(x,width)=width*floor(x/width) + upload_binwidth/2.0
    plot '/tmp/download_speeds.txt' using (download_bin(\$1,download_binwidth)):(1.0) smooth frequency with boxes title "Download", \
         '/tmp/upload_speeds.txt' using (upload_bin(\$1,upload_binwidth)):(1.0) smooth frequency with boxes title "Upload"

EOFMarker

#!/bin/bash

# Input file
input_file="$opt_file"

# Output file
output_file="/tmp/speeds_vs_time.txt"
# Remove existing output file

# Gnuplot script
gnuplot_script="/init/plot_speeds.gp"

# Execute Gnuplot with the generated script
gnuplot -persist "$gnuplot_script"


# Recipient email address
recipient="iu5ofy.qsl@gmail.com"

# SMTP server details
smtp_server="smtp.gmail.com"
smtp_port="587"  # Port for SMTP submission (587 is common for TLS)

# Sender email address and authentication details
sender="speedteststarlink@gmail.com"
password="hvuxrhhiudchuejq"  # Replace with your actual password

# Email subject and body
subject="Speed Test Results"
body="Please find the attached speed test results."
cc1="tecnoroby@gmail.com"
# Attachments
attachment1="/tmp/speeds_histogram.png"
attachment2="/tmp/speeds_vs_time.png"

# Send email with attachments using sendemail
sendemail -f "$sender" \
    -t "$recipient" \
    -cc "$cc1" \
    -u "$subject" \
    -m "$body" \
    -s "$smtp_server":"$smtp_port" \
    -xu "$sender" \
    -xp "$password" \
    -o tls=yes \
    -a "$attachment1" \
    -a "$attachment2"

echo "Email sent to $recipient"


# Clean up temporary files
rm /tmp/speedtest_filtered.txt /tmp/download_speeds.txt /tmp/upload_speeds.txt /tmp/speeds_histogram.png /tmp/speeds_vs_time.png
