#!/bin/bash
	inp_file=/tmp/speedtest.txt
	out_file=/home/server2/speedtest.txt
	speedtest-cli > "$inp_file"
        echo -n  "$(cat "$inp_file" | grep 'Download:') " >> "$out_file"
        echo -n "$(cat "$inp_file" | grep 'Upload:') " >> "$out_file"
        echo -n "$(hwclock --show | cut -d'.' -f1)" >> "$out_file"
	echo "" >> "$out_file"
	rm /tmp/speedtest.txt

