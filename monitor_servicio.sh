#!/bin/bash

intervalo=5
log_ruta="/var/log/monitor_sistema.l"

while true; do
    timestamp=$(/usr/bin/date '+%Y-%m-%d %H:%M:%S')
    procesos_top5=$(/bin/ps -e -o pid,comm,%cpu,%mem --sort=-%cpu | /usr/bin/head -6)
    echo "=== $timestamp ===" >> "$log_ruta"
    echo "$procesos_top5" >> "$log_ruta"
    echo "" >> "$log_ruta"
    /bin/sleep $intervalo
done

