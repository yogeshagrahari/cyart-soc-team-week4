# Lab 7 — Security Metrics & Executive Reporting

## 1. Summary

This lab builds complete proficiency in **SOC metrics collection**, **dashboard creation**, **dwell time analysis**, and **professional executive reporting**. Deliverables include a real Elastic dashboard, a Google Sheets metrics tracker, and a 150-word executive summary.

### Incident Background

On **03 April 2026**, the Security Operations Centre (SOC) detected, investigated, and contained a threat originating from internal host `10.0.2.20`. The attacker established persistence, initiated command-and-control (C2) communications, and exfiltrated approximately **2.4 GB** of data before being contained.

### 1.1 Week 4 SOC Metrics Overview

| Metric | Formula | Week 4 Value | Target | Trend |
|--------|---------|-------------|--------|-------|
| MTTD | Detect Time − Compromise Time | 2.0 hrs | < 1.0 hr | IMPROVING |
| MTTR | Resolve Time − Detect Time | 4.0 hrs | < 1.0 hr | STABLE |
| Dwell Time | MTTD + MTTR | 6.0 hrs | < 2.0 hrs | NEEDS ACTION |
| False Positive Rate | (FP / Total Alerts) × 100 | 18% | < 10% | NEEDS TUNING |
| True Positive Rate | (TP / (TP+FN)) × 100 | 78% | > 90% | IMPROVING |
| Alert-to-Ticket Ratio | Tickets / Total Alerts | 0.23 | 0.15–0.30 | NORMAL |
| Incident Resolution Rate | Closed / Opened (30-day) | 94% | > 95% | NEAR TARGET |
| Detection Coverage | ATT&CK Techniques Covered / Total | 68% | > 80% | NEEDS WORK |
| Playbook Automation Rate | Auto-resolved / Total | 42% | > 70% | IMPROVING |
| Analyst Utilisation | Active Work Time / Shift Time | 71% | 60–80% | OPTIMAL |

### 1.2 Create Elastic Security Metrics Dashboard

```
1. Open Elastic: http://localhost:5601 → Dashboard → Create Dashboard
2. Panel 1 (MTTD Trend):       Lens → Line chart → X-axis: date, Y-axis: avg(@timestamp diff)
3. Panel 2 (Alert Volume):     Bar chart → X-axis: date, Y-axis: count(event.kind:alert)
4. Panel 3 (FP Rate):          Metric → formula: count(false_positive) / count(*) * 100
5. Panel 4 (Top MITRE):        Tag Cloud → threat.technique.name
6. Panel 5 (MTTR Gauge):       Gauge → compare avg MTTR against 240-min SLA
7. Save dashboard as:          "Week4-SOC-Metrics-Dashboard"
8. Export screenshot for executive report
```

---

## 2. Dwell Time Analysis

### Incident Dwell Time Table

| Incident ID | Compromise Time | Detection Time | Dwell Time | Risk Assessment |
|-------------|----------------|----------------|------------|-----------------|
| INC-001 | 2026-03-30 08:00 | 2026-03-30 09:15 | 75 min | MEDIUM — contained quickly |
| INC-002 | 2026-03-31 22:00 | 2026-04-01 06:00 | 480 min | HIGH — overnight, undetected |
| INC-003 | 2026-04-01 08:00 | 2026-04-01 10:00 | 120 min | HIGH — above 60-min target |
| INC-004 | 2026-04-02 14:00 | 2026-04-02 14:05 | 5 min | LOW — automated detection |
| **AVERAGE** | — | — | **170 min** | **ABOVE TARGET (<60 min)** |

### Dwell Time Python Script

Save as `dwell_time_analysis.py`:

```python
# dwell_time_analysis.py | Date: 30-03-2026
from datetime import datetime

incidents = [
    {"id": "SOC-2026-001", "name": "Phishing Attack",
     "compromise": "2026-03-30 09:00", "detect": "2026-03-30 11:00",
     "resolve":   "2026-03-30 15:00"},
    {"id": "SOC-2026-002", "name": "Malware C2",
     "compromise": "2026-03-30 14:30", "detect": "2026-03-30 14:55",
     "resolve":   "2026-03-30 16:30"},
    {"id": "SOC-2026-003", "name": "Privilege Escalation",
     "compromise": "2026-03-30 10:15", "detect": "2026-03-30 10:30",
     "resolve":   "2026-03-30 11:45"},
]

fmt = "%Y-%m-%d %H:%M"
print(f"{'ID':<16} {'Incident':<25} {'MTTD':>8} {'MTTR':>8} {'Dwell':>8}")
print("-" * 70)

total_mttd = total_mttr = total_dwell = 0
for inc in incidents:
    c    = datetime.strptime(inc["compromise"], fmt)
    d    = datetime.strptime(inc["detect"],     fmt)
    r    = datetime.strptime(inc["resolve"],    fmt)
    mttd = (d - c).total_seconds() / 60
    mttr = (r - d).total_seconds() / 60
    dwell = mttd + mttr
    total_mttd += mttd; total_mttr += mttr; total_dwell += dwell
    print(f"{inc['id']:<16} {inc['name']:<25} {mttd:>7.0f}m {mttr:>7.0f}m {dwell:>7.0f}m")

n = len(incidents)
print("-" * 70)
print(f"{'AVERAGE':<41} {total_mttd/n:>7.0f}m {total_mttr/n:>7.0f}m {total_dwell/n:>7.0f}m")
```

**Expected Output:**

```
ID               Incident                   MTTD     MTTR    Dwell
----------------------------------------------------------------------
SOC-2026-001     Phishing Attack             120m     240m     360m
SOC-2026-002     Malware C2                   25m      95m     120m
SOC-2026-003     Privilege Escalation         15m      75m      90m
----------------------------------------------------------------------
AVERAGE                                       53m     137m     190m
```

---

## 3. Elastic Security Dashboard Configuration

### Panel Configurations

```bash
# Navigate: Kibana > Dashboard > Create Dashboard

# Visualization 1: MTTD Over Time (Line Chart)
# Aggregation: Average of mttd_minutes | X-axis: @timestamp (daily)
# Index: wazuh-alerts-* | Filter: event.category: "intrusion_detection"

# Visualization 2: Alert Volume by Severity (Bar Chart)
# Aggregation: Count | Split series: rule.level
# Color: 0-7=Low(green), 8-11=Medium(orange), 12-15=High(red)

# Visualization 3: False Positive Rate (Gauge — Scripted Field)
POST kibana/api/index_patterns/wazuh-alerts-*/fields
{
  "field": {
    "name": "fp_rate",
    "type": "number",
    "scripted": true,
    "script": { "source": "doc['rule.level'].value < 3 ? 1 : 0" }
  }
}

# Visualization 4: MITRE ATT&CK Coverage (Heat Map)
# Elastic SIEM > Overview > MITRE ATT&CK tab | Filter: agent.ip: "10.0.2.20"

# Visualization 5: Top Threat Actors (Data Table)
# Aggregation: Terms on rule.mitre.technique | Size: 10 | Sort: Count DESC

# Save Dashboard as: "SOC-Week4-Metrics-Dashboard"
```

### Dashboard Panels (Detailed)

| Panel | Type | Title |
|-------|------|-------|
| Panel 1 | Donut/Bar Chart | Alert Volume by Severity — Last 7 Days |
| Panel 2 | Horizontal Bar | Top 10 Triggered Rules |
| Panel 3 | Treemap | Alert Distribution by Endpoint |
| Panel 4 | Line Chart | High-Severity Alerts — Hourly Trend |
| Metric 1 | KPI Tile | High Severity Alerts (7d) |
| Metric 2 | KPI Tile | Active Agents |
| Metric 3 | KPI Tile | Critical Alerts Today |
| Metric 4 | KPI Tile | Potential False Positives (7d) |

### Export Dashboard

```
Kibana: Dashboard menu (top-right) → Share → PDF/PNG Reports
Set: Page layout = Full page
Save as: elastic_soc_dashboard_week4.png
Add to: /Week4/Module5_Metrics/screenshots/
```

---

## 4. Google Sheets Metrics Tracker

### Sheet 1: `Incident_Data` — Raw Incident Records

| Column | Field | Example | Formula |
|--------|-------|---------|---------|
| A | Incident_ID | INC001 | — |
| B | Date | 2025-08-18 | — |
| C | Severity | High | — |
| D | Incident_Start | 10:00 | — |
| E | Alert_Fired | 12:00 | — |
| F | Contained | 12:30 | — |
| G | Closed | 16:00 | — |
| H | MTTD_Hours | — | `=(E2-D2)*24` |
| I | MTTR_Hours | — | `=(F2-E2)*24` |
| J | Dwell_Hours | — | `=(F2-D2)*24` |
| K | False_Positive | TRUE/FALSE | — |
| L | Escalated_L2 | TRUE/FALSE | — |
| M | MITRE_TTP | T1566 | — |
| N | Resolution | IP_Blocked | — |

### Sheet 2: `Dashboard` — Calculated Metrics

```
Cell B2: =AVERAGE(Incident_Data!H:H)                                  → Avg MTTD
Cell B3: =AVERAGE(Incident_Data!I:I)                                  → Avg MTTR
Cell B4: =AVERAGE(Incident_Data!J:J)                                  → Avg Dwell
Cell B5: =COUNTIF(Incident_Data!K:K,TRUE)/COUNTA(Incident_Data!A:A)*100  → FP%
Cell B6: =COUNTIF(Incident_Data!L:L,TRUE)/COUNTA(Incident_Data!A:A)*100  → Escalation%
Cell B7: =COUNTIF(Incident_Data!H:H,"<=1")/COUNTA(Incident_Data!A:A)*100 → MTTD SLA%
```

**Add these charts in Sheet 2:**
- Bar chart: MTTD/MTTR comparison vs. targets
- Pie chart: Severity distribution from Sheet 1
- Line chart: MTTD trend over time

---

## 5. Python Metrics Analysis Script

Save as `week4_metrics.py`:

```python
#!/usr/bin/env python3
# week4_metrics.py — Complete SOC metrics calculation
# Date: 30-03-2026 | Team: cyart-soc-team

from datetime import datetime
import json

fmt = "%Y-%m-%d %H:%M"

incidents = [
    {"id": "SOC-2026-001", "type": "Phishing",
     "compromise": datetime.strptime("2026-03-30 09:00", fmt),
     "detect":     datetime.strptime("2026-03-30 11:00", fmt),
     "resolve":    datetime.strptime("2026-03-30 15:00", fmt), "fp": False},
    {"id": "SOC-2026-002", "type": "Malware C2",
     "compromise": datetime.strptime("2026-03-30 14:30", fmt),
     "detect":     datetime.strptime("2026-03-30 14:55", fmt),
     "resolve":    datetime.strptime("2026-03-30 16:30", fmt), "fp": False},
    {"id": "SOC-2026-003", "type": "Privilege Escalation",
     "compromise": datetime.strptime("2026-03-30 10:15", fmt),
     "detect":     datetime.strptime("2026-03-30 10:30", fmt),
     "resolve":    datetime.strptime("2026-03-30 11:45", fmt), "fp": False},
]

mttds  = [(i['detect']  - i['compromise']).seconds // 60 for i in incidents]
mttrs  = [(i['resolve'] - i['detect']).seconds     // 60 for i in incidents]
dwells = [m + r for m, r in zip(mttds, mttrs)]

total_alerts    = 47
false_positives = 9

metrics = {
    "week"             : "30-03-2026 to 05-04-2026",
    "total_incidents"  : len(incidents),
    "total_alerts"     : total_alerts,
    "false_positives"  : false_positives,
    "fp_rate_pct"      : round((false_positives / total_alerts) * 100, 1),
    "avg_mttd_min"     : round(sum(mttds)  / len(mttds),  1),
    "avg_mttr_min"     : round(sum(mttrs)  / len(mttrs),  1),
    "avg_dwell_min"    : round(sum(dwells) / len(dwells), 1),
    "max_dwell_min"    : max(dwells),
    "min_dwell_min"    : min(dwells),
}

print(json.dumps(metrics, indent=2))
print(f"\nMTTD  per incident: {mttds}")
print(f"MTTR  per incident: {mttrs}")
print(f"Dwell per incident: {dwells}")

with open("week4_metrics.json", "w") as f:
    json.dump(metrics, f, indent=2)
print("\n[OK] Metrics saved to week4_metrics.json")
```

---

## 6. Stakeholder Briefing (Non-Technical, 150 words)

> **STAKEHOLDER BRIEFING — NON-TECHNICAL EXECUTIVE VERSION**

On 30 March 2026, our Security Operations team identified and neutralised a targeted phishing attack against our network. An employee received a deceptive email that appeared to come from IT support; when opened, it attempted to gain access to internal systems. Our automated security systems detected the attack within **2 hours** and our team blocked the source within **4 hours** — no sensitive data was compromised.

Over the past week, our security team processed over **700 alerts**, with detection speed improving by **35%** and response speed improving by **25%**. Our false alarm rate dropped from 12% to just **5%**, meaning analysts spend more time on real threats.

Three actions have been approved to prevent similar incidents: strengthening our email security settings, deploying an email threat sandbox, and conducting company-wide phishing awareness training. Our security posture is measurably improving week-over-week.

---

## 7. Executive Security Report

```
Date:    03 April 2026
To:      CISO / Executive Team
From:    SOC Team — Week 4 Operations
Period:  30 March 2026 – 05 April 2026
```

### Summary

The Security Operations Centre handled **5 security incidents** this week, including 1 critical server exploitation attempt and 2 privilege escalation cases. All incidents were detected and contained within target SLA windows. **No customer data or production systems were compromised.**

### Performance Highlights

| KPI | Result |
|-----|--------|
| Mean Time to Detect (MTTD) | 0.65 hours *(35% improvement vs. last week)* |
| Mean Time to Respond (MTTR) | 0.48 hours *(well within 4-hour target)* |
| Average Dwell Time | 1.26 hours *(vs. industry avg: 204 days)* |
| Automation Success | 100% — 5/5 SOAR playbook executions succeeded |
| Detection Coverage | 75% of tested TTPs *(target: 95%)* |

### Risk Dashboard

| Indicator | Status |
|-----------|--------|
| Overall Risk Level | **MEDIUM** *(reduced from HIGH)* |
| New Threats Detected | 3 (T1210, T1566, T1078) |
| Threats Contained | 3 of 3 (100%) |
| Open Cases | 0 *(all closed within SLA)* |

### Key Metrics Snapshot

| Metric | This Week | Last Week | Target | Status |
|--------|-----------|-----------|--------|--------|
| Total Alerts | 287 | 312 | < 300 |  ON TARGET |
| Confirmed Incidents | 3 | 5 | < 5 |  ON TARGET |
| MTTD (avg) | 53 min | 72 min | < 60 min |  ON TARGET |
| MTTR (avg) | 137 min | 180 min | < 60 min |  IMPROVING |
| False Positive Rate | 18% | 22% | < 10% |  NEEDS WORK |
| Automation Rate | 42% | 35% | > 70% |  IMPROVING |
| Critical Gaps Found | 1 (T1041) | 2 | 0 | ACTION NEEDED |

### Top Recommendations *(estimated 3-week delivery)*

| # | Action | Cost | Risk Reduction | Timeline |
|---|--------|------|----------------|----------|
| 1 | Implement URL detonation sandbox for T1566.002 detection gap | $400/month | HIGH | 2 weeks |
| 2 | Enable Just-In-Time admin access to reduce T1078 exposure | $0 (Azure AD P2) | HIGH | 1 week |
| 3 | Expand adversary emulation to include T1082 and T1053 | Internal time only | MEDIUM | 2 weeks |

**Compliance Status:** Aligned with CISA CPGs 1.A, 2.B, 2.D, 3.A  
**Prepared by:** Yogesh | **Next Report:** April 2026

---

## 8. Recommendations

1. **Deploy Wazuh exfiltration detection rule for T1041 within 48 hours**
2. **Enforce MFA on all email accounts** to reduce phishing risk by an estimated 95%
3. **Increase SOAR playbook coverage** from 42% to 70% target by 30-04-2026
4. **Schedule monthly phishing simulations** to reduce user-click rate below 5%
5. **Tune Wazuh false positive rules** to reduce FP rate from 18% to under 10%

---

##  File Structure

```
Lab7-Security-Metrics/
├── dwell_time_analysis.py       # Dwell time calculation script
├── week4_metrics.py             # Complete SOC metrics calculation
├── week4_metrics.json           # Generated metrics output (JSON)
├── screenshots/
│   └── elastic_soc_dashboard_week4.png
├── google_sheets/
│   ├── Incident_Data.csv        # Raw incident records
│   └── Dashboard_formulas.txt  # Sheet 2 formula reference
└── README.md                    # This file
```

---

##  Metric Formulas Reference

| Metric | Formula |
|--------|---------|
| MTTD | `Detect Time − Compromise Time` |
| MTTR | `Resolve Time − Detect Time` |
| Dwell Time | `MTTD + MTTR` |
| False Positive Rate | `(FP / Total Alerts) × 100` |
| True Positive Rate | `(TP / (TP + FN)) × 100` |
| Alert-to-Ticket Ratio | `Tickets / Total Alerts` |
| Incident Resolution Rate | `Closed / Opened (30-day)` |
| Detection Coverage | `ATT&CK Techniques Covered / Total` |
| Playbook Automation Rate | `Auto-resolved / Total` |
| Analyst Utilisation | `Active Work Time / Shift Time` |

---

## Contact

**CYART SOC Training**  
 inquiry@cyart.io | www.cyart.io
