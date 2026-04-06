# Section 02 — Advanced SOAR Automation

## Objective
Design, implement, and test a SOAR playbook that automates phishing incident response including IP reputation checks, automated blocking, and TheHive case creation.

---

## SOAR Architecture

```
Alert Triggered (Wazuh)
        │
        |
[Splunk Phantom / TheHive]
        │
        ├── Step 1: Extract IOCs (IP, Hash, Domain)
        │
        ├── Step 2: Check IP Reputation (VirusTotal / OTX)
        │
        ├── Step 3: Block IP via CrowdSec (if malicious)
        │
        ├── Step 4: Create TheHive Case (auto-ticket)
        │
        └── Step 5: Notify SOC Analyst (email/Slack)
```

---

## Playbook: PHI-001 — Phishing Auto-Response

| Field              | Value                                |
|--------------------|--------------------------------------|
| **Playbook ID**    | PHI-001                              |
| **Trigger**        | Wazuh Rule 100002 — Phishing Alert   |
| **Priority**       | High                                 |
| **Created**        | 30 March 2026                        |
| **Tested**         | 31 March 2026                        |
| **Status**         | Active                               |

---

## Steps Summary

| Step | Action                         | Tool           | Expected Output              |
|------|--------------------------------|----------------|------------------------------|
| 1    | Parse alert, extract source IP | Splunk Phantom | IP: `10.0.2.20`              |
| 2    | Query VirusTotal for IP rep    | VirusTotal API | Score: Malicious (72/90)     |
| 3    | Block IP                       | CrowdSec       | `10.0.2.20` added to blocklist |
| 4    | Create incident ticket         | TheHive        | Case ID: TH-2026-0401        |
| 5    | Alert SOC team                 | Email/Slack    | Notification sent            |

---

## Full Documentation → [`playbook-documentation.md`](./playbook-documentation.md)

---

## References
- [Splunk SOAR Documentation](https://docs.splunk.com/Documentation/SOAR)
- [TheHive Project](https://thehive-project.org/)
- [CISA SOAR Guide](https://www.cisa.gov/resources-tools/resources/soar)
