#  Section 06 — Capstone Project: Comprehensive SOC Incident Response

## Overview

The capstone integrates all Week 4 skills in a single end-to-end exercise: attack simulation, detection, triage, containment, SOAR automation, adversary emulation, post-incident analysis, metrics, and stakeholder reporting.

---

## Scenario

A threat actor at `10.0.2.20` exploited a Samba vulnerability on the Metasploitable2 target (`192.168.10.5`), gaining unauthorized access. The SOC team detected the intrusion via Wazuh, triaged the alert in TheHive, blocked the attacker via CrowdSec, emulated follow-on TTPs with Caldera, performed RCA, and produced a full executive report.

---

## Attack Chain

```
[Attacker: 10.0.2.20]
        │
        │ 1. Phishing email sent → T1566
        │
        |
[User testuser — 192.168.10.5]
        │
        │ 2. Credential compromise → T1078
        │
        |
[Metasploitable2: 192.168.10.5]
        │
        │ 3. Samba exploit (usermap_script) → T1210
        │
        |
[Root shell obtained]
        │
        │ 4. Privilege escalation, lateral movement → T1068, T1021
        │
        ▼
[Wazuh Alert → TheHive → SOAR → CrowdSec Block]
```

---

## Capstone Documents

| File                          | Description                                  |
|-------------------------------|----------------------------------------------|
| `capstone-full-report.md`     | 300-word SANS-template full incident report  |
| `stakeholder-briefing.md`     | 150-word non-technical executive briefing    |
| `chain-of-custody.md`         | Evidence log with SHA256 hashes              |
| `sub-reports/attack-simulation.md`    | Metasploit attack steps + output     |
| `sub-reports/detection-triage.md`     | Wazuh alerts + TheHive triage        |
| `sub-reports/response-containment.md`| CrowdSec block + VM isolation        |
| `sub-reports/soar-automation.md`      | SOAR playbook execution log          |
| `sub-reports/post-incident-metrics.md`| Final metrics + dashboard            |

---

## Capstone Timeline

| Date        | Activity                                          |
|-------------|---------------------------------------------------|
| 01 Apr 2026 | Attack simulation (Metasploit — Samba exploit)    |
| 01 Apr 2026 | Adversary emulation (Caldera — T1210)             |
| 01 Apr 2026 | Detection in Wazuh + Triage in TheHive            |
| 01 Apr 2026 | Containment via CrowdSec + VM isolation           |
| 01 Apr 2026 | SOAR playbook execution                           |
| 02 Apr 2026 | Post-incident RCA + Fishbone diagram              |
| 02 Apr 2026 | Metrics calculation + Elastic dashboard           |
| 02 Apr 2026 | Full report + Executive briefing written          |
