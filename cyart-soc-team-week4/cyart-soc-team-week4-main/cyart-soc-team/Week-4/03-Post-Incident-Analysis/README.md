# Section 03 — Post-Incident Analysis & Continuous Improvement

## Objective
Conduct a structured Root Cause Analysis (RCA) of the phishing incident involving `10.0.2.20`, document lessons learned, and calculate SOC performance metrics (MTTD / MTTR).

---

## Incident Reference

| Field              | Value                                         |
|--------------------|-----------------------------------------------|
| **Incident ID**    | INC-2026-0330                                 |
| **Type**           | Phishing / Credential Compromise              |
| **Source IP**      | `10.0.2.20`                                   |
| **Detection Date** | 30 March 2026 — 09:14 AM                      |
| **Resolved Date**  | 30 March 2026 — 01:20 PM                      |
| **Severity**       | High                                          |

---

## RCA Methods Used

| Method            | Purpose                              | Tool       |
|-------------------|--------------------------------------|------------|
| 5 Whys            | Identify root cause chain            | Google Sheets |
| Fishbone Diagram  | Visualize contributing factors       | Draw.io    |
| Lessons Learned   | Prevent recurrence                   | Google Docs |

---

## Documents in this Section

| File                         | Description                         |
|------------------------------|-------------------------------------|
| `rca-report.md`              | Full 5 Whys analysis + Lessons Learned |
| `metrics-calculation.md`     | MTTD, MTTR, dwell time, false positive rate |

---

## Quick Metrics Summary

| Metric                  | Value         |
|-------------------------|---------------|
| Mean Time to Detect     | 2 hours       |
| Mean Time to Respond    | 2 hours 6 min |
| Total Dwell Time        | ~4 hours      |
| False Positive Rate     | 12%           |
| Incident Resolution     | 30 March 2026 |
