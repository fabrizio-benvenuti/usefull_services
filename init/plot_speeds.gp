#!/usr/bin/gnuplot

# Input file
in_file="/tmp/speedtest_filtered.txt"

# Output file
out_file="/tmp/speeds_vs_time.png"

# Set terminal to PNG with cairo support
set terminal pngcairo enhanced font "arial,10" fontscale 1.0 size 800, 600

# Set plot properties
set output out_file
set xlabel "Time"
set ylabel "Speed (Mbit/s)"
set title "Download and Upload Speeds over Time (last 12 hours)"
set xdata time
set timefmt "%Y-%m-%d %H:%M:%S"
set format x "%d %H:%M"
set key top left
set ytics 10
set grid

# Plot the data
plot in_file using 3:1 with linespoints title "Download Speed", \
     "" using 3:2 with linespoints title "Upload Speed"
