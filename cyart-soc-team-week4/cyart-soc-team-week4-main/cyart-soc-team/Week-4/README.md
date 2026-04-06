#  Week 4 — Advanced SOC Operations
## cyart-soc-team | SOC Analyst Training Program

---

##  Overview

| Field              | Details                                  |
|--------------------|------------------------------------------|
| **Team**           | cyart-soc-team                           |
| **Week**           | Week 4 — Advanced SOC Operations        |
| **Duration**       | 30 March 2026 – 02 April 2026            |
| **Deadline**       | 03 April 2026 — 5:30 PM                  |
| **Attacker IP**    | `10.0.2.20`                              |
| **Environment**    | Metasploitable2, Wazuh, Elastic, Caldera |

---

##  Repository Structure

```
Week-4/
├── README.md                          ← You are here
│
├── 01-Threat-Hunting/
│   ├── README.md                      ← Methodology & steps
│   ├── threat-hunting-report.md       ← Full hunting report
│   └── screenshots/                   ← Evidence (add manually)
│
├── 02-SOAR-Automation/
│   ├── README.md                      ← Playbook overview
│   ├── playbook-documentation.md      ← Full playbook docs
│   └── screenshots/
│
├── 03-Post-Incident-Analysis/
│   ├── README.md                      ← RCA overview
│   ├── rca-report.md                  ← 5 Whys + Fishbone
│   ├── metrics-calculation.md         ← MTTD / MTTR
│   └── screenshots/
│
├── 04-Adversary-Emulation/
│   ├── README.md                      ← Emulation overview
│   ├── emulation-report.md            ← Caldera simulation docs
│   └── screenshots/
│
├── 05-Security-Metrics/
│   ├── README.md                      ← Metrics overview
│   ├── executive-report.md            ← Non-technical executive summary
│   ├── metrics-dashboard.md           ← Elastic dashboard notes
│   └── screenshots/
│
└── 06-Capstone-Project/
    ├── README.md                      ← Capstone overview
    ├── capstone-full-report.md        ← 300-word SANS-template report
    ├── stakeholder-briefing.md        ← 150-word exec briefing
    ├── chain-of-custody.md            ← Evidence log
    └── sub-reports/
        ├── attack-simulation.md
        ├── detection-triage.md
        ├── response-containment.md
        ├── soar-automation.md
        └── post-incident-metrics.md
```

---

## Timeline

| Date           | Activity                                          |
|----------------|---------------------------------------------------|
| 30 Mar 2026    | Environment setup, threat hunting hypothesis      |
| 30 Mar 2026    | SOAR playbook design, Wazuh configuration         |
| 31 Mar 2026    | Adversary emulation (Caldera), detection testing  |
| 31 Mar 2026    | Post-incident RCA, Fishbone diagram               |
| 01 Apr 2026    | Capstone: Attack simulation (Metasploit)          |
| 01 Apr 2026    | Capstone: Detection, triage, containment          |
| 02 Apr 2026    | Metrics calculation, Elastic dashboard            |
| 02 Apr 2026    | Executive report, stakeholder briefing, submission|

---

## Tools Used

| Tool              | Purpose                                      |
|-------------------|----------------------------------------------|
| Wazuh             | SIEM — detection & alerting                  |
| Elastic Security  | Log analysis, dashboards, metrics            |
| MITRE Caldera     | Adversary emulation (T1566, T1210, T1078)    |
| Metasploit        | Attack simulation (Capstone)                 |
| TheHive           | Case management & SOAR                       |
| CrowdSec          | IP blocking / automated containment          |
| Splunk Phantom    | SOAR playbook automation                     |
| Velociraptor      | Endpoint forensics & evidence collection     |
| FTK Imager        | Disk image & chain-of-custody                |
| AlienVault OTX    | Threat intelligence feed                     |
| VirusTotal        | IOC / hash validation                        |
| Draw.io           | Fishbone diagram                             |
| Google Docs/Sheets| Reporting & metrics tracking                 |

---

##  MITRE ATT&CK Techniques Covered

| Technique ID | Name                              | Context                        |
|--------------|-----------------------------------|--------------------------------|
| T1078        | Valid Accounts                    | Threat Hunting                 |
| T1566        | Phishing                          | Adversary Emulation            |
| T1210        | Exploitation of Remote Services   | Capstone — Samba exploit       |
| T1059        | Command and Scripting Interpreter | Post-exploitation activity     |
| T1110        | Brute Force                       | Detection testing              |

---

##  Submission Checklist

- [ ] 01 — Threat Hunting Report + Screenshots
- [ ] 02 — SOAR Playbook Documentation + Test Results
- [ ] 03 — Post-Incident RCA + Fishbone Diagram + Metrics
- [ ] 04 — Adversary Emulation Report + Wazuh Detection Logs
- [ ] 05 — Security Metrics Dashboard + Executive Report
- [ ] 06 — Capstone: Full Report + Stakeholder Briefing + Chain-of-Custody
- [ ] All PDFs exported and added to `/screenshots` folders
- [ ] Repository made public at: `github.com/cyart-soc-team`

---


