#  Sub-Report 2: Detection & Triage
**Date:** 01 April 2026
**Attacker IP:** `10.0.2.20`
**Target IP:** `192.168.10.5`

---

## Wazuh Alert Log

| Alert ID     | Timestamp           | Source IP   | Dest IP       | Rule ID | Severity | MITRE | Description                        |
|--------------|---------------------|-------------|---------------|---------|----------|-------|------------------------------------|
| WAZUH-190041 | 2026-04-01 08:05:14 | 10.0.2.20   | 192.168.10.5  | 5712    | High     | T1210 | Samba exploitation attempt         |
| WAZUH-190042 | 2026-04-01 08:05:44 | 10.0.2.20   | 192.168.10.5  | 100010  | Critical | T1210 | Remote command shell opened        |
| WAZUH-190043 | 2026-04-01 08:06:01 | 10.0.2.20   | 192.168.10.5  | 4672    | High     | T1078 | Privilege escalation (root)        |
| WAZUH-190044 | 2026-04-01 08:06:30 | 10.0.2.20   | 192.168.10.5  | 4688    | Medium   | T1059 | Shell command execution detected   |
| WAZUH-190045 | 2026-04-01 08:07:00 | 10.0.2.20   | 192.168.10.5  | 5501    | High     | T1087 | User enumeration via /etc/passwd   |

---

## TheHive Triage

### Case Details

| Field           | Value                                         |
|-----------------|-----------------------------------------------|
| Case ID         | TH-2026-0401                                  |
| Title           | INC-2026-0401: Samba Exploit — 10.0.2.20      |
| Severity        | High (3)                                      |
| TLP             | AMBER                                         |
| PAP             | AMBER                                         |
| Tags            | T1210, samba, exploit, capstone, week4        |
| Status          | In Progress → Resolved                        |
| Assigned To     | SOC Analyst                                   |
| Created         | 2026-04-01 08:20 AM                           |
| Closed          | 2026-04-01 11:30 AM                           |

### Triage Tasks

| Task #  | Task Name              | Status      | Notes                                |
|---------|------------------------|-------------|--------------------------------------|
| T-01    | Validate Alert         |  Done     | Confirmed true positive via VT       |
| T-02    | Identify Source IP     |  Done     | 10.0.2.20 — OTX confirmed malicious  |
| T-03    | Identify Target        |  Done     | 192.168.10.5 — Metasploitable2       |
| T-04    | Check for Lateral Move |  Done     | SMB to 192.168.10.1 (failed)         |
| T-05    | Lock Accounts          |  Done     | testuser + admin_temp locked         |
| T-06    | Block Source IP        |  Done     | CrowdSec — 72h ban                   |
| T-07    | Isolate Host           |  Done     | VM network disconnected              |
| T-08    | Post-Incident RCA      |  Done     | 5 Whys completed                    |

### IOC Observables Added to TheHive

| Observable          | Type       | Source      | Malicious |
|---------------------|------------|-------------|-----------|
| 10.0.2.20           | IP Address | Wazuh Alert |  Yes    |
| 192.168.10.5        | IP Address | Target host |  Internal |
| samba 3.0.20        | Service    | Nmap        |  Vulnerable |
| cmd/unix/reverse    | Payload    | Metasploit  |  Yes    |

---

## Alert Disposition

| Alert ID     | Classification  | Action Taken              |
|--------------|-----------------|---------------------------|
| WAZUH-190041 | True Positive   | Escalated → TH-2026-0401  |
| WAZUH-190042 | True Positive   | Escalated → TH-2026-0401  |
| WAZUH-190043 | True Positive   | Escalated → TH-2026-0401  |
| WAZUH-190044 | True Positive   | Escalated → TH-2026-0401  |
| WAZUH-190045 | True Positive   | Escalated → TH-2026-0401  |

---

*Sub-Report Author: SOC Analyst | cyart-soc-team | 01 April 2026*
