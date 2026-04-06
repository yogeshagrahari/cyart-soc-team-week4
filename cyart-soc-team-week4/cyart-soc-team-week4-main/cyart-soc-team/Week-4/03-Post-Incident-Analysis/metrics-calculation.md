#  SOC Metrics Calculation — INC-2026-0330
**Incident:** INC-2026-0330 | Phishing / Privilege Escalation
**Attacker IP:** `10.0.2.20`
**Date:** 30 March 2026
**Analyst:** SOC Analyst — cyart-soc-team

---

## 1. Key SOC Metrics Definitions

| Metric                   | Definition                                                              |
|--------------------------|-------------------------------------------------------------------------|
| **MTTD**                 | Mean Time to Detect — time from compromise to first alert               |
| **MTTR**                 | Mean Time to Respond — time from alert to full containment              |
| **Dwell Time**           | Total time attacker was active before full eviction                     |
| **False Positive Rate**  | % of alerts that were not real threats                                  |
| **Incident Resolution Rate** | % of incidents fully resolved within SLA                           |

---

## 2. Incident Timeline for Calculation

| Event                         | Timestamp (30 Mar 2026) |
|-------------------------------|--------------------------|
| Initial Compromise            | 07:14 AM                 |
| First Alert Triggered (Wazuh) | 09:14 AM                 |
| SOC Analyst Assigned          | 09:30 AM                 |
| Containment Started           | 10:05 AM                 |
| Full Containment              | 11:20 AM                 |
| Incident Resolved             | 01:20 PM                 |

---

## 3. MTTD Calculation

```
MTTD = Time of Detection − Time of Compromise
     = 09:14 AM − 07:14 AM
     = 2 hours 0 minutes
```

**MTTD = 2 hours**

> Industry benchmark: < 1 hour. Current MTTD of 2 hours indicates detection rule tuning is needed.

---

## 4. MTTR Calculation

```
MTTR = Time of Full Containment − Time of First Alert
     = 11:20 AM − 09:14 AM
     = 2 hours 6 minutes
```

**MTTR = 2 hours 6 minutes**

>  Within acceptable range (<4 hours). SOAR automation reduced manual response time.

---

## 5. Dwell Time Calculation

```
Dwell Time = Time of Full Eviction − Time of Initial Compromise
           = 01:20 PM − 07:14 AM
           = 6 hours 6 minutes
```

**Dwell Time = ~6 hours**

>  Target dwell time: < 2 hours. 6-hour dwell indicates room for improvement.

---

## 6. False Positive Rate

During the week of 30 March – 02 April 2026:

| Total Alerts | True Positives | False Positives | False Positive Rate |
|--------------|----------------|-----------------|---------------------|
| 108          | 95             | 13              | **12.0%**           |

```
FP Rate = (False Positives / Total Alerts) × 100
        = (13 / 108) × 100
        = 12.0%
```

>  Target: < 10%. At 12%, some Wazuh rules require threshold adjustment.

---

## 7. Summary Dashboard

| Metric                  | Value         | Target       | Status      |
|-------------------------|---------------|--------------|-------------|
| MTTD                    | 2 hours       | < 1 hour     |  Needs work |
| MTTR                    | 2h 6 min      | < 4 hours    |  Within SLA |
| Dwell Time              | 6 hours       | < 2 hours    |  Needs work |
| False Positive Rate     | 12.0%         | < 10%        |  Needs work |
| Incidents Resolved (SLA)| 1/1 = 100%    | > 95%        |   Met       |
| Playbook Automation Time| 47 seconds    | < 5 min      |   Excellent |

---

## 8. Metrics Analysis Summary

The phishing incident INC-2026-0330 revealed that MTTD (2 hours) and dwell time (6 hours) exceed recommended benchmarks. The primary gap is in early detection — Wazuh rules for T1078 privilege escalation needed tuning to alert faster. MTTR performed well (2h 6min) due to SOAR automation reducing manual steps. The 12% false positive rate suggests rule threshold refinement is needed. Recommended focus areas: tighten detection rules, integrate earlier threat intelligence triggers, and reduce dwell time through network segmentation.

---

*Metrics Author: SOC Analyst | cyart-soc-team | 31 March 2026*
