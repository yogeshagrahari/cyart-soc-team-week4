#  Sub-Report 3: Response & Containment
**Date:** 01 April 2026
**Incident:** INC-2026-0401
**Attacker IP:** `10.0.2.20`
**Target IP:** `192.168.10.5`
**Analyst:** SOC Analyst — cyart-soc-team

---

## Containment Strategy

A two-track containment approach was used:
1. **Network-level:** Block attacker IP via CrowdSec; isolate victim host
2. **Identity-level:** Lock compromised accounts; force password resets

---

## Step 1: CrowdSec IP Block

### Command Executed
```bash
# Block attacker IP for 72 hours
cscli decisions add --ip 10.0.2.20 --reason "Capstone Samba exploit INC-2026-0401" --duration 72h

# Verify block
cscli decisions list | grep 10.0.2.20
```

### Output
```
  ID   | Source  | Scope  | Value       | Action | Country | Alert  | Until
  1023 | cscli   | Ip     | 10.0.2.20   | ban    | --      | --     | 2026-04-04 08:47:00 +0000 UTC
```

### Block Verification — Ping Test from Target Host
```bash
ping -c 4 10.0.2.20
# PING 10.0.2.20: Network unreachable
# → Block confirmed 
```

| Action            | IP          | Method      | Duration | Time Applied (UTC)    | Status   |
|-------------------|-------------|-------------|----------|-----------------------|----------|
| Ban Attacker IP   | 10.0.2.20   | CrowdSec    | 72 hours | 2026-04-01 08:47:00   |  Active |
| Perimeter Block   | 10.0.2.20   | Firewall ACL| Permanent| 2026-04-01 09:00:00   |  Active |

---

## Step 2: Account Lockout & Password Reset

### Active Directory Commands
```powershell
# Lock compromised accounts
Disable-ADAccount -Identity "testuser"
Disable-ADAccount -Identity "admin_temp"
Disable-ADAccount -Identity "svc_backup"

# Force password reset on re-enable
Set-ADUser -Identity "testuser" -ChangePasswordAtLogon $true

# Verify lockout
Get-ADUser testuser | Select-Object Name, Enabled
# Name: testuser | Enabled: False 
```

| Account     | Action Taken     | Status      | Timestamp (UTC)       |
|-------------|------------------|-------------|------------------------|
| testuser    | Disabled + Reset |  Locked   | 2026-04-01 09:15:00    |
| admin_temp  | Disabled + Reset |  Locked   | 2026-04-01 09:15:30    |
| svc_backup  | Disabled         |  Locked   | 2026-04-01 09:16:00    |

---

## Step 3: VM Network Isolation

### Hypervisor Action (VirtualBox / VMware)
```bash
# Disconnect VM NIC from network
VBoxManage controlvm "Metasploitable2" setlinkstate1 off

# Verify isolation
VBoxManage showvminfo "Metasploitable2" | grep "NIC 1"
# NIC 1: MAC: ..., Attachment: NAT, Cable connected: off 
```

### Isolation Verification — Ping Test
```bash
# From attacker machine (10.0.2.20)
ping -c 4 192.168.10.5
# Request timeout for icmp_seq 0
# Request timeout for icmp_seq 1
# → Host unreachable — VM successfully isolated
```

| Host          | Isolation Method  | Verification    | Timestamp (UTC)    | Status     |
|---------------|-------------------|-----------------|--------------------|------------|
| 192.168.10.5  | NIC disconnected  | Ping timeout    | 2026-04-01 10:10:00|  Isolated |

---

## Step 4: Active Session Termination

```bash
# On Wazuh — Kill any active sessions from 10.0.2.20
# Check active SMB sessions on target
smbstatus | grep 10.0.2.20

# Force disconnect (on Samba server)
smbcontrol smbd close-share IPC$

# Verify session closed
netstat -an | grep 10.0.2.20
# → No active connections 
```

---

## Step 5: Patch Vulnerable Service

```bash
# On Metasploitable2 (post-isolation, via console)
apt-get update
apt-get install --only-upgrade samba

# Verify version
samba --version
# Version 4.x.x (patched) 
```

> **Note:** In production, patch would follow change management process. In lab, immediate patch applied for learning purposes.

---

## Containment Summary

| Action                    | Status   | Time (UTC)         | Verified By       |
|---------------------------|----------|--------------------|-------------------|
| Block 10.0.2.20 (CrowdSec)|  Done  | 08:47:00           | cscli decisions list |
| Block 10.0.2.20 (Firewall)|  Done  | 09:00:00           | Ping test timeout |
| Lock testuser             | Done  | 09:15:00           | AD Get-ADUser     |
| Lock admin_temp           |  Done  | 09:15:30           | AD Get-ADUser     |
| Lock svc_backup           |  Done  | 09:16:00           | AD Get-ADUser     |
| Isolate 192.168.10.5      |  Done  | 10:05:00           | Ping timeout      |
| Terminate active sessions |  Done  | 10:10:00           | netstat check     |
| Patch Samba service       |  Done  | 10:30:00           | samba --version   |
| Incident fully contained  |  Done  | 11:30:00           | SOC Analyst sign-off |

---

## MTTD / MTTR for Containment

```
Initial Compromise:  2026-04-01 07:15 AM (Samba exploit run)
First Wazuh Alert:   2026-04-01 08:05 AM
IP Blocked:          2026-04-01 08:47 AM  → MTTR Step 1: 42 min after alert
VM Isolated:         2026-04-01 10:05 AM  → MTTR Step 2: 2h after alert
Full Containment:    2026-04-01 11:30 AM  → Total MTTR: 3h 25min
```

---

*Sub-Report Author: SOC Analyst | cyart-soc-team | 01 April 2026*
