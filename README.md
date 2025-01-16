# SystemIsolate

**SystemIsolate** is a collection of incident response resources, tools, and scripts I have developed and studied as part of my study of incident response. This repository is designed to help professionals and enthusiasts understand key techniques in isolating, investigating, and remediating security incidents.

---

## Overview

This repository provides insights into:
- **System Isolation**: Techniques to quickly contain threats by isolating a compromised system from the network.
- **Forensic Data Collection**: Scripts and methods to gather critical evidence during an incident response.
- **Incident Response Automation**: Automating response tasks to reduce reaction time.
- **Undo Actions**: Steps to restore the system to normal operations after containment.

---

## Incident Response Script

### `incidentscript.sh`

A versatile Bash script to:
- **Isolate the System**: Blocks all incoming and outgoing traffic using `iptables` to air-gap the machine.
- **Collect Evidence**: Gathers system information, running processes, network activity, and logs for further analysis.
- **Undo Isolation**: Restores network connectivity and resets firewall rules.

### Usage

1. Clone the repository:
    ```bash
    git clone https://github.com/systemisolate/incidentscript.sh
    cd SystemIsolate
    ```

2. Make the script executable:
    ```bash
    chmod +x incidentscript.sh
    ```

3. Run the script:
    - To isolate the system and collect data:
      ```bash
      sudo ./incidentscript.sh -run
      ```
    - To undo the isolation:
      ```bash
      sudo ./incidentscript.sh -undo
      ```

4. View logs and reports:
    - All logs and reports are saved in `/tmp/ir_logs/` with a timestamp for easy retrieval.

---

## Features

- **Rapid Network Isolation**: Uses `iptables` to block traffic in real-time.
- **Comprehensive Data Collection**:
  - System info (kernel, logged-in users).
  - Running processes and active network connections.
  - Recent system logs and cron jobs.
  - Hashes of critical binaries for integrity checks.
- **Automated SOC Reporting**: Generates detailed reports for use by security teams.
- **Error Handling**: Provides clear messages if actions fail (e.g., insufficient privileges).

---
