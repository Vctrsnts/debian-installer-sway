#!/bin/bash

# CPU usage (%)
cpu_usage=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {printf "%.0f", usage}')
cpu_icon=""

# Memory usage (%)
mem_usage=$(free | awk '/Mem:/ {printf "%.0f", $3/$2 * 100}')
mem_icon=""

# Disk free space in /home
disk_free=$(df -h /home | awk 'NR==2 {print $4}')
disk_icon=""

# Output format
echo "$cpu_icon ${cpu_usage}%  $mem_icon ${mem_usage}%  $disk_icon ${disk_free}"
