#!/bin/bash

LOG_DIR="/var/log"
LOG_FILE="$LOG_DIR/system_health.log"
MAX_LOG_SIZE=$((10  * 1024 * 1024))

#Creates a directory if the specified path is present.
mkdir -p $LOG_DIR

log_cpu_usage() {
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
    echo "[`date '+%Y-%m-%d %H:%M:%S'`] CPU Usage: $CPU_USAGE%" >> $LOG_FILE
}

log_memory_usage() {
    MEM_TOTAL=$(free -h | awk '/^Mem/ {print $2}')
    MEM_FREE=$(free -h | awk '/^Mem/ {print $4}')
    echo "[`date '+%Y-%m-%d %H:%M:%S'`] Memory Usage: Total: $MEM_TOTAL, Free: $MEM_FREE" >> $LOG_FILE
}

log_disk_usage() {
    DISK_ROOT=$(df -h / | awk 'NR==2 {print $5}')
    DISK_VAR=$(df -h /var | awk 'NR==2 {print $5}')
    echo "[`date '+%Y-%m-%d %H:%M:%S'`] Disk Usage: /: $DISK_ROOT, /var: $DISK_VAR" >> $LOG_FILE
}

log_active_processes() {
    ACTIVE_PROCESSES=$(ps aux | wc -l)
    echo "[`date '+%Y-%m-%d %H:%M:%S'`] Active Processes: $ACTIVE_PROCESSES" >> $LOG_FILE
}

log_top_memory_processes() {
    echo "[`date '+%Y-%m-%d %H:%M:%S'`] Top 5 Memory-Consuming Processes:" >> $LOG_FILE
    ps aux --sort=-%mem | head -6 | awk 'NR>1 {printf "    %d. %s (PID: %s) - %s\n", NR-1, $11, $2, $4}' >> $LOG_FILE
}

rotate_log() {
    if [ -f $LOG_FILE ] && [ $(stat -c%s $LOG_FILE) -gt $MAX_LOG_SIZE ]; then
        mv $LOG_FILE "$LOG_DIR/system_health_$(date '+%Y%m%d_%H%M%S').log"
    fi
}

main() {
    rotate_log
    log_cpu_usage
    log_memory_usage
    log_disk_usage
    log_active_processes
    log_top_memory_processes
}

main

