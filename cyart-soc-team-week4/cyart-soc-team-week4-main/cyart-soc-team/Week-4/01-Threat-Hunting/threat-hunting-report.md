#  Threat Hunting Report — T1078 Valid Accounts
**Analyst:** SOC Analyst — cyart-soc-team
**Date:** 30 March 2026
**Technique Hunted:** T1078 — Valid Accounts
**Source IP of Interest:** `10.0.2.20`

---

## 1. Executive Summary

During the threat hunting exercise conducted on 30 March 2026, the SOC team identified suspicious privilege escalation activity linked to source IP `10.0.2.20`. A domain account (`testuser`) was observed receiving unexpected administrative role assignments, consistent with MITRE ATT&CK T1078 (Valid Accounts). The activity was confirmed as a true positive after cross-referencing with AlienVault OTX threat intelligence and Velociraptor process telemetry.

---

## 2. Hunting Hypothesis

**Hypothesis:** An adversary is leveraging Valid Accounts to perform privilege escalation within the domain environment.

**Trigger:** AlienVault OTX flagged `10.0.2.20` as associated with credential abuse activity in a recent threat intelligence pulse.

**MITRE Technique:** T1078 — Valid Accounts
**Sub-technique:** T1078.002 — Domain Accounts

---

## 3. Event Log Findings (Elastic Security — Event ID 4672)

| Timestamp            | User       | Source IP   | Event ID | Logon Type | Notes                          |
|----------------------|------------|-------------|----------|------------|--------------------------------|
| 2026-03-30 09:14:33  | testuser   | 10.0.2.20   | 4672     | Network    | Unexpected admin role assigned |
| 2026-03-30 09:22:47  | svc_backup | 10.0.2.20   | 4672     | Service    | Service account privilege use  |
| 2026-03-30 10:05:12  | admin_temp | 10.0.2.20   | 4624     | Network    | Successful logon — off-hours   |
| 2026-03-30 11:33:58  | testuser   | 10.0.2.20   | 4672     | Network    | Second privilege escalation    |
| 2026-03-31 08:44:21  | testuser   | 10.0.2.20   | 4672     | Network    | Repeated admin role activity   |
| 2026-03-31 14:20:09  | svc_backup | 10.0.2.20   | 4648     | Explicit   | Explicit credential use        |
| 2026-04-01 07:55:44  | admin_temp | 10.0.2.20   | 4672     | Network    | Admin access — new workstation |

**Total Events Flagged:** 7
**Confirmed Suspicious:** 5
**False Positives Removed:** 2 (scheduled backup tasks)

---

## 4. Velociraptor Process Telemetry

Query executed:
```sql
SELECT Name, Pid, Ppid, CommandLine, Username, CreateTime
FROM processes
WHERE Username LIKE '%admin%' OR CommandLine LIKE '%net user%' OR CommandLine LIKE '%whoami%'
```

| Name        | PID  | Parent PID | Command Line              | Username    | Timestamp            |
|-------------|------|------------|---------------------------|-------------|----------------------|
| cmd.exe     | 1842 | 1380       | cmd.exe /c net user       | testuser    | 2026-03-30 09:15:01  |
| whoami.exe  | 2031 | 1842       | whoami /priv              | testuser    | 2026-03-30 09:15:04  |
| net.exe     | 2055 | 1842       | net localgroup administrators | testuser | 2026-03-30 09:15:09 |
| powershell  | 3112 | 1380       | Get-LocalGroupMember      | svc_backup  | 2026-03-30 09:23:10  |

**Assessment:** `testuser` executed `net user`, `whoami /priv`, and attempted to enumerate local admin group — consistent with post-compromise privilege discovery.

---

## 5. AlienVault OTX — Threat Intelligence Cross-Reference

| IOC               | Type       | OTX Pulse                           | Match in Logs | Confidence |
|-------------------|------------|-------------------------------------|---------------|------------|
| 10.0.2.20         | IP Address | APT Credential Abuse Campaign 2026  |  Yes         | High       |
| testuser_hash_abc | File Hash  | Mimikatz Derivative Tool Set        |  Yes         | High       |
| svc_backup        | Username   | Lateral Movement Service Accounts   |  Yes         | Medium     |

---

## 6. Network Connection Analysis (Wazuh)

| Timestamp            | Source IP   | Dest IP        | Port | Protocol | Description                   |
|----------------------|-------------|----------------|------|----------|-------------------------------|
| 2026-03-30 09:14:00  | 10.0.2.20   | 192.168.10.5   | 445  | SMB      | SMB session — pre-escalation  |
| 2026-03-30 09:16:00  | 10.0.2.20   | 192.168.10.1   | 389  | LDAP     | LDAP query — user enumeration |
| 2026-03-31 08:40:00  | 10.0.2.20   | 192.168.10.5   | 445  | SMB      | Lateral movement via SMB      |
| 2026-04-01 07:50:00  | 10.0.2.20   | 192.168.10.10  | 3389 | RDP      | RDP logon — admin_temp        |

---

## 7. Hunting Report Summary

**Finding:** IP `10.0.2.20` is actively being used to perform privilege escalation via valid domain accounts (T1078). The account `testuser` received unexpected admin role assignments on 30 March 2026. Velociraptor telemetry confirmed execution of privilege enumeration commands (`net user`, `whoami /priv`). AlienVault OTX corroborated `10.0.2.20` as a known malicious IP in active threat intelligence feeds. The activity spanned three days (30 March – 01 April 2026) and included SMB lateral movement and an RDP session to a second host. Immediate account lockout and IP blocking were recommended and executed via CrowdSec. Findings are escalated to the Tier 2 team for further investigation and mapped to T1078.002 in MITRE ATT&CK.

**Recommended Actions:**
1. Lock `testuser` and `admin_temp` accounts immediately
2. Force password reset for `svc_backup`
3. Block `10.0.2.20` at perimeter firewall and CrowdSec
4. Enable MFA for all domain admin accounts
5. Review and tighten least-privilege policies

---

## 8. MITRE ATT&CK Mapping

| Tactic              | Technique       | Sub-technique           | Observed Behavior              |
|---------------------|-----------------|-------------------------|--------------------------------|
| Privilege Escalation| T1078           | T1078.002 (Domain Acct) | Admin role assignment          |
| Discovery           | T1087           | T1087.002               | net user, LDAP enumeration     |
| Lateral Movement    | T1021.002       | SMB/Windows Admin Share | SMB connection to 192.168.10.5 |
| Credential Access   | T1003           | —                       | Suspected Mimikatz usage       |

---

*Report Author: SOC Analyst | cyart-soc-team | 30 March 2026*
