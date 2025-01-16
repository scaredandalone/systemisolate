#!/bin/bash

# Incident Response script
# Author: scaredandalone
# Purpose: Incident response script with options to isolate a system, collect data, and undo isolation.

LOG_DIR="/tmp/ir_logs"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
REPORT_FILE="$LOG_DIR/report_$TIMESTAMP.txt"

# Function: Run Incident Response
run_incident_response() {
    mkdir -p "$LOG_DIR"
    echo "==== INCIDENT RESPONSE STARTED [$TIMESTAMP] ====" | tee -a "$REPORT_FILE"

    # Step 1: Network Isolation
    echo "[1] Cutting off network access..." | tee -a "$REPORT_FILE"
    iptables -P INPUT DROP
    iptables -P OUTPUT DROP
    iptables -P FORWARD DROP
    echo "Network isolation in place. System is now air-gapped." | tee -a "$REPORT_FILE"

    # Step 2: Collect Forensic Data
    echo "[2] Collecting system info..." | tee -a "$REPORT_FILE"

    echo "--> System Info:" | tee -a "$REPORT_FILE"
    uname -a >> "$REPORT_FILE"

    echo "--> Who's logged in:" | tee -a "$REPORT_FILE"
    who >> "$REPORT_FILE"

    echo "--> Running processes:" | tee -a "$REPORT_FILE"
    ps aux > "$LOG_DIR/process_list.txt"
    echo "Processes saved to $LOG_DIR/process_list.txt" | tee -a "$REPORT_FILE"

    echo "--> Network activity:" | tee -a "$REPORT_FILE"
    netstat -tulnp > "$LOG_DIR/netstat.txt"
    echo "Network connections saved to $LOG_DIR/netstat.txt" | tee -a "$REPORT_FILE"

    echo "--> Recent logs (last hour):" | tee -a "$REPORT_FILE"
    journalctl --since "1 hour ago" > "$LOG_DIR/recent_logs.txt"
    echo "Logs saved to $LOG_DIR/recent_logs.txt" | tee -a "$REPORT_FILE"

    # Step 3: Check for Weird Stuff
    echo "[3] Running quick checks for anything odd..." | tee -a "$REPORT_FILE"

    echo "--> Scheduled tasks:" | tee -a "$REPORT_FILE"
    crontab -l > "$LOG_DIR/cron_jobs.txt" 2>/dev/null || echo "No cron jobs for current user" >> "$REPORT_FILE"
    echo "Cron jobs saved to $LOG_DIR/cron_jobs.txt" | tee -a "$REPORT_FILE"

    echo "--> Dumping hashes of system binaries (you might need these later):" | tee -a "$REPORT_FILE"
    hashes_file="$LOG_DIR/file_hashes_$TIMESTAMP.txt"
    find /bin /sbin /usr/bin /usr/sbin -type f -exec sha256sum {} \; > "$hashes_file"
    echo "Hashes saved to $hashes_file" | tee -a "$REPORT_FILE"

    # Step 4: SOC Report
    echo "[4] Wrapping it all up for the SOC team..." | tee -a "$REPORT_FILE"
    SOC_REPORT="$LOG_DIR/SOC_Report_$TIMESTAMP.txt"

    cat << EOF > "$SOC_REPORT"
Incident Response Summary - $TIMESTAMP

Actions Taken:
- System isolated (network blocked via iptables)
- Collected system info, running processes, and active connections
- Grabbed recent logs and cron jobs
- Calculated hashes of key system binaries

Artifacts:
- Process List: $LOG_DIR/process_list.txt
- Network Connections: $LOG_DIR/netstat.txt
- Logs: $LOG_DIR/recent_logs.txt
- File Hashes: $hashes_file
- Cron Jobs: $LOG_DIR/cron_jobs.txt

Next Steps:
1. Review collected artifacts for signs of compromise.
2. Look for unusual processes, connections, or cron jobs.
3. Share this report with the SOC team for deeper analysis.

EOF

    echo "SOC report ready: $SOC_REPORT" | tee -a "$REPORT_FILE"

    echo "==== INCIDENT RESPONSE COMPLETE ====" | tee -a "$REPORT_FILE"
}

# Function: Undo Isolation
undo_isolation() {
    echo "==== UNDOING SYSTEM ISOLATION ===="

    echo "[1] Resetting iptables rules to allow all traffic..."
    iptables -P INPUT ACCEPT
    iptables -P OUTPUT ACCEPT
    iptables -P FORWARD ACCEPT
    iptables -F

    echo "Network access restored. All traffic is now allowed."

    echo "[2] Verifying iptables status..."
    iptables -L -v -n

    echo "==== ISOLATION REVERSED ===="
}

# Main Script Logic
case "$1" in
    -run)
        run_incident_response
        ;;
    -undo)
        undo_isolation
        ;;
    *)
        echo "Usage: $0 -run | -undo"
        echo "  -run    Run the incident response process"
        echo "  -undo   Undo the isolation and restore network access"
        ;;
esac
