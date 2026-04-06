# Lab 4 — Alert Triage with Automation

> **CYART SOC Training Series**  
> Date: 31 March 2026 |  Tools: Wazuh · VirusTotal · TheHive

---

## 1. Overview & Objectives

Wazuh is an open-source **Security Information and Event Management (SIEM)** platform that collects, aggregates, and analyzes log data from endpoints, servers, cloud workloads, and network devices.

In this lab you will learn how to triage a **Suspicious File Download** alert raised by Wazuh, document findings in a structured format, and hand off the case to TheHive for further investigation.

**Learning Goals:**
- Understand the Wazuh alert hierarchy and rule-set framework
- Navigate the Wazuh Dashboard and locate Alert ID 005
- Perform initial triage: classify, enrich, and prioritise the alert
- Document the alert in the standardised SOC triage table
- Extract IoCs (Indicators of Compromise) for downstream validation
- Escalate or close the alert with a documented decision

---

## 2. Environment Setup

### Minimum Requirements

| Component | Minimum Spec | Recommended |
|-----------|-------------|-------------|
| OS | Ubuntu 20.04 LTS | Ubuntu 22.04 LTS |
| RAM | 4 GB | 8 GB |
| CPU | 2 vCPU | 4 vCPU |
| Disk | 50 GB | 100 GB SSD |
| Wazuh Manager | v4.3+ | v4.7+ |
| Wazuh Dashboard | OpenSearch 2.x | OpenSearch 2.x |
| Python | 3.8+ | 3.10+ |

### 2.1 Install Wazuh (All-In-One)

```bash
# Step 1 — Download the Wazuh installation assistant
curl -sO https://packages.wazuh.com/4.7/wazuh-install.sh

# Step 2 — Make it executable
chmod +x wazuh-install.sh

# Step 3 — Run all-in-one installation (~10 minutes)
sudo bash wazuh-install.sh -a

# Step 4 — Retrieve auto-generated credentials
sudo tar -O -xvf wazuh-install-files.tar wazuh-install-files/wazuh-passwords.txt

# Step 5 — Start / verify services
sudo systemctl status wazuh-manager
sudo systemctl status wazuh-indexer
sudo systemctl status wazuh-dashboard
```

### 2.2 Deploy Wazuh Agent on Target Host (10.0.2.20)

```bash
# Download & install agent
wget https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.7.5-1_amd64.deb
sudo WAZUH_MANAGER='' WAZUH_AGENT_NAME='endpoint-10.0.2.20' \
  dpkg -i ./wazuh-agent_4.7.5-1_amd64.deb

# Enable and start the agent
sudo systemctl daemon-reload
sudo systemctl enable wazuh-agent
sudo systemctl start wazuh-agent

# Verify agent status
sudo systemctl status wazuh-agent

# On manager — confirm agent appears
sudo /var/ossec/bin/manage_agents -l
```

---

## 3. Alert Simulation — Triggering the File Download Alert

### 3.1 Enable File Integrity Monitoring

Edit the Wazuh agent configuration on `10.0.2.20`:

```bash
sudo nano /var/ossec/etc/ossec.conf
```

Add or verify this block inside `<syscheck>`:

```xml
<syscheck>
  <disabled>no</disabled>
  <frequency>300</frequency>
  <directories check_all="yes" report_changes="yes" realtime="yes">/home</directories>
  <directories check_all="yes" report_changes="yes" realtime="yes">/tmp</directories>
  <alert_new_files>yes</alert_new_files>
</syscheck>
```

```bash
sudo systemctl restart wazuh-agent
```

### 3.2 Simulate the Suspicious Download

```bash
# Create a fake malicious file in /tmp
echo 'X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*' \
  > /tmp/suspicious_download.exe

# Simulate wget download behavior
cd /tmp && wget -q -O malware_sample.bin \
  https://secure.eicar.org/eicar.com.txt 2>/dev/null || \
  echo 'fake-payload-data' > malware_sample.bin

# Force Wazuh syscheck scan immediately
sudo /var/ossec/bin/agent_control -r -u 001
```

### 3.3 Verify Alert in Wazuh Dashboard

1. Open browser → `https://<MANAGER_IP>` → login with admin credentials
2. Click **Security Events** in the left sidebar
3. Set time range to **Last 15 minutes**
4. In the search bar type: `agent.ip: 10.0.2.20 AND rule.groups: syscheck`
5. Locate the alert with **Rule ID 554** (New file added) or **550** (Integrity checksum changed)
6. Click the alert row to expand the full JSON payload

---

## 4. Alert Triage Documentation

| Field | Value |
|-------|-------|
| Alert ID | 005 |
| Alert Title | Suspicious File Download Detected |
| Detection Time | 30-03-2026 09:14:32 UTC |
| Source IP | 10.0.2.20 |
| Destination IP | External (pending enrichment) |
| Affected Host | endpoint-10.0.2.20 |
| OS | Ubuntu 22.04 LTS |
| User Account | ubuntu (uid=1000) |
| File Path | /tmp/suspicious_download.exe |
| File Hash (SHA256) | 44d88612fea8a8f36de82e1278abb02f (EICAR test) |
| File Size | 68 bytes |
| Wazuh Rule ID | 554 / 550 |
| Rule Group | syscheck, ossec |
| MITRE Tactic | Execution (TA0002) / Initial Access (TA0001) |
| MITRE Technique | T1105 — Ingress Tool Transfer |
| Priority | HIGH |
| Status | OPEN |
| Assigned Analyst | SOC Tier-1 |
| Initial Action | Isolate host, extract IoC, forward to TheHive |

---

## 5. Step-by-Step Triage Workflow

**STEP 1 — Acknowledge the Alert**  
In Wazuh Dashboard, right-click Alert ID 005 → *Mark as Acknowledged*. This flags the alert as under investigation and prevents duplicate triage.

**STEP 2 — Validate the Source IP**
```bash
grep '10.0.2.20' /var/ossec/etc/client.keys
sudo /var/ossec/bin/manage_agents -l | grep '10.0.2.20'
```

**STEP 3 — Extract the Raw Alert JSON**
```bash
curl -k -u admin:PASSWORD \
  'https://localhost:9200/wazuh-alerts-*/_search?q=agent.ip:10.0.2.20' \
  -H 'Content-Type: application/json' | python3 -m json.tool
```

**STEP 4 — Hash the Suspicious File**
```bash
md5sum /tmp/suspicious_download.exe
sha1sum /tmp/suspicious_download.exe
sha256sum /tmp/suspicious_download.exe
# Expected: 44d88612fea8a8f36de82e1278abb02f  suspicious_download.exe
```

**STEP 5 — Check Network Connections**
```bash
ss -tunap | grep ESTABLISHED
netstat -tunap 2>/dev/null
cat /var/log/syslog | grep '10.0.2.20' | grep -i 'dns\|resolv'
```

**STEP 6 — MITRE ATT&CK Mapping**

| Tactic | Technique ID | Technique Name | Observed Evidence |
|--------|-------------|----------------|-------------------|
| Initial Access | T1566.002 | Spearphishing Link | File appeared via download |
| Execution | T1105 | Ingress Tool Transfer | Binary dropped in /tmp |
| Persistence | T1547 | Boot/Logon Autostart | Investigate startup entries |
| Defense Evasion | T1036 | Masquerading | .exe disguised in /tmp |

**STEP 7 — Determine Disposition**  
Choose one of: **True Positive** → escalate to TheHive | **False Positive** → document and tune the rule | **Benign Positive** → whitelist with justification.

---

## 6. Custom Wazuh Detection Rule

Create `/var/ossec/etc/rules/local_rules.xml`:

```xml
<!-- Custom rule: Suspicious file download from internal host -->
<group name="syscheck,local,">
  <rule id="100200" level="12">
    <if_sid>554</if_sid>
    <field name="file">\.exe$|\.bin$|\.sh$|\.py$</field>
    <description>Alert 005: Suspicious executable file added — possible download</description>
    <group>pci_dss_11.5,gpg13_4.13,gdpr_II_5.1.f</group>
    <mitre><id>T1105</id></mitre>
  </rule>
  <rule id="100201" level="15">
    <if_sid>100200</if_sid>
    <field name="agent.ip">10\.0\.2\.20</field>
    <field name="file">^/tmp/|^/home/</field>
    <description>HIGH: Suspicious binary in /tmp or /home on 10.0.2.20</description>
  </rule>
</group>
```

```bash
# Validate and reload
sudo /var/ossec/bin/ossec-logtest
sudo systemctl reload wazuh-manager
```

---

## 7. Automated VirusTotal Hash Check via Python

### 7.1 VirusTotal API v3 Endpoints

| Endpoint | Purpose |
|----------|---------|
| `GET /files/{hash}` | Query file reputation by MD5/SHA1/SHA256 |
| `GET /ip_addresses/{ip}` | Query IP reputation |
| `GET /domains/{domain}` | Query domain reputation |
| `POST /files` | Upload file for scanning |
| `GET /analyses/{id}` | Retrieve scan analysis results |

---

## 8. Obtaining & Configuring the API Key

1. Visit [https://www.virustotal.com](https://www.virustotal.com) and create a free account
2. Navigate to your profile → **API Key** tab
3. Copy the 64-character hexadecimal API key
4. Store it securely as an environment variable:

```bash
export VT_API_KEY='YOUR_64_CHAR_API_KEY_HERE'

# Make persistent across reboots
echo 'export VT_API_KEY=YOUR_KEY' >> ~/.bashrc
source ~/.bashrc
```

---

## 9. Automated Validation Python Script

Save as `vt_validator.py`:

```python
#!/usr/bin/env python3
"""
vt_validator.py — Automated IoC Validation via VirusTotal API v3
Alert ID 005 | Source: 10.0.2.20 | Date: 30-03-2026
"""
import os, sys, json, time, requests
from datetime import datetime

API_KEY  = os.environ.get("VT_API_KEY", "")
BASE_URL = "https://www.virustotal.com/api/v3"
HEADERS  = {"x-apikey": API_KEY, "Accept": "application/json"}

ALERT = {
    "id"        : "005",
    "source_ip" : "10.0.2.20",
    "file_path" : "/tmp/suspicious_download.exe",
    "md5"       : "44d88612fea8a8f36de82e1278abb02f",
    "sha256"    : "275a021bbfb6489e54d471899f7db9d1663fc695ec2fe2a2c4538aabf651fd0f",
    "date"      : "30-03-2026",
}

def check_file_hash(hash_val):
    url = f"{BASE_URL}/files/{hash_val}"
    r = requests.get(url, headers=HEADERS, timeout=30)
    return r.json() if r.status_code == 200 else {"error": "hash_not_found"}

def check_ip(ip):
    url = f"{BASE_URL}/ip_addresses/{ip}"
    r = requests.get(url, headers=HEADERS, timeout=30)
    return r.json()

def main():
    if not API_KEY:
        print("[ERROR] VT_API_KEY environment variable not set.")
        sys.exit(1)

    print(f"\n{'='*60}")
    print(f" VT Validator — Alert ID: {ALERT['id']}")
    print(f" Date: {ALERT['date']} | Source IP: {ALERT['source_ip']}")
    print(f"{'='*60}\n")

    hash_data = check_file_hash(ALERT['md5'])
    attrs     = hash_data.get("data", {}).get("attributes", {})
    stats     = attrs.get("last_analysis_stats", {})
    malicious = stats.get("malicious", 0)
    total     = sum(stats.values())

    print(f"[*] Checking MD5: {ALERT['md5']}")
    print(f"    Verdict    : {'MALICIOUS' if malicious > 3 else 'CLEAN'}")
    print(f"    Detections : {malicious}/{total} engines")

    time.sleep(15)  # respect free-tier rate limit

    ip_data = check_ip(ALERT['source_ip'])
    print(f"\n[*] Checking IP: {ALERT['source_ip']}")
    print(f"    Result : {ip_data.get('data',{}).get('attributes',{}).get('country','N/A')}")

    with open("vt_report_005.json", "w") as f:
        json.dump({"alert_id": ALERT['id'], "hash_stats": stats}, f, indent=2)
    print("\n[OK] Full report saved to vt_report_005.json")

if __name__ == "__main__":
    main()
```

```bash
pip3 install requests
python3 vt_validator.py
```

---

## 10. Expected Script Output

```
============================================================
 VT Validator — Alert ID: 005
 Date: 30-03-2026 | Source IP: 10.0.2.20
============================================================
[*] Checking MD5 hash: 44d88612fea8a8f36de82e1278abb02f
    Verdict    : MALICIOUS
    Detections : 68/72 engines
    File Type  : text
[*] Checking IP: 10.0.2.20
    Country    : Private RFC1918
    Owner      : Internal Network
    Verdict    : CLEAN

[50-WORD SUMMARY]
Alert 005 | Source: 10.0.2.20 | Date: 30-03-2026.
File hash flagged as MALICIOUS by 68/72 VT engines.
IP reputation: CLEAN, 0 detections. MITRE T1105.
Escalate to TheHive immediately for case management.
============================================================
```

---

## 11. TheHive & Cortex Architecture

| Component | Role | Port |
|-----------|------|------|
| TheHive 5 | Case/alert management UI & API | 9000 |
| Cortex 3 | Analyzer & responder orchestrator | 9001 |
| Elasticsearch | Data storage backend | 9200 |
| VirusTotal API | External threat intel feed | 443 |
| Wazuh Manager | SIEM — alert source | 55000 |

---

## 12. Installing TheHive + Cortex

### 12.1 Install Dependencies

```bash
sudo apt update && sudo apt install -y openjdk-11-jre-headless \
  curl wget gnupg apt-transport-https python3-pip docker.io
```

### 12.2 Deploy via Docker Compose

Create `/opt/thehive/docker-compose.yml` and run:

```bash
cd /opt/thehive
docker-compose up -d

# Verify all containers running
docker-compose ps
```

---

## 13. Configuring the VirusTotal Analyzer in Cortex

1. Open Cortex UI → `http://<SERVER_IP>:9001`
2. Login as admin (first-run wizard sets the password)
3. Navigate to **Organization → Analyzers** tab
4. Search for `VirusTotal_GetReport` → click **Enable**
5. Click the gear icon → enter your VT API key
6. Set Rate limiting: `4 req/min` (free tier)
7. Click **Save** → the analyzer turns green (Active)
8. Also enable `VirusTotal_Scan` for unknown hashes

---

## 14. Linking TheHive to Cortex

In TheHive, go to **Admin → Cortex Servers** and add:

| Setting | Value |
|---------|-------|
| Cortex URL | `http://cortex:9001` |
| API Key | *(from Cortex → API keys → create org key)* |
| Name | Cortex-Primary |
| Auto-run | Yes — for hash and IP observables |

```bash
# Generate API key via Cortex REST API
curl -XPOST http://localhost:9001/api/user/cortex/key/renew \
  -H 'Content-Type: application/json' \
  -u admin:password | jq .key
```

---

## 15. Creating Alert 005 as a TheHive Case

```bash
python3 thehive_create_case.py
```

The script will:
- Create a case titled **"Alert 005 — Suspicious File Download from 10.0.2.20"**
- Set severity to **HIGH** and TLP to **AMBER**
- Attach tasks: Triage, VT hash check, lateral movement check, host isolation, case closure
- Add observables: file hash (MD5), source IP, and filename

---

## 16. Triggering Auto-Analysis via Cortex

```bash
python3 cortex_analyze.py
```

The script submits the hash to `VirusTotal_GetReport_3_1`, polls for job completion, and prints a structured verdict with detection count and summary.

---

## 17. Configure Auto-Notification in TheHive

1. Go to **TheHive Admin → Notifications**
2. Click **+ Add Notification**
3. Trigger: `AnyEvent` → filter: `observable.dataType = 'hash'`
4. Action: `RunAnalyzer` → select `VirusTotal_GetReport_3_1`
5. Set Min TLP: **Amber (2)**
6. Click **Save**

---

## File Structure

```
Lab4-Alert-Triage/
├── vt_validator.py          # VirusTotal IoC validation script
├── thehive_create_case.py   # TheHive case creation script
├── cortex_analyze.py        # Cortex auto-analysis trigger
├── vt_report_005.json       # Generated VT report output
├── local_rules.xml          # Custom Wazuh detection rule
└── README.md                # This file
```

---

## Contact

**CYART SOC Training**  
 inquiry@cyart.io |  www.cyart.io
