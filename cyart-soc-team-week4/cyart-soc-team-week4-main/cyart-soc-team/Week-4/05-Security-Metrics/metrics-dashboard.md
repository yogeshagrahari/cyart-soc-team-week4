# Elastic Security — Metrics Dashboard Configuration
**Dashboard Name:** SOC Week 4 — Performance Metrics
**Created:** 02 April 2026
**Analyst:** SOC Analyst — cyart-soc-team

---

## Dashboard Overview

The Elastic Security dashboard was configured to display real-time and historical SOC performance metrics for the Week 4 period (30 March – 02 April 2026).

---

## Panels Configured

### Panel 1: MTTD — Line Chart
```json
{
  "title": "Mean Time to Detect (MTTD)",
  "type": "line",
  "index": "wazuh-alerts-*",
  "query": {
    "metric": "avg",
    "field": "time_to_detect_minutes",
    "date_range": {
      "from": "2026-03-30",
      "to": "2026-04-02"
    }
  },
  "reference_line": 60,
  "reference_label": "Target: 60 min"
}
```
**Current Value:** 120 minutes (2 hours)
**Target:** 60 minutes

---

### Panel 2: MTTR — Gauge
```json
{
  "title": "Mean Time to Respond (MTTR)",
  "type": "gauge",
  "min": 0,
  "max": 480,
  "thresholds": [
    {"value": 0,   "color": "green"},
    {"value": 240, "color": "yellow"},
    {"value": 360, "color": "red"}
  ],
  "current_value": 126
}
```
**Current Value:** 126 minutes (2h 6min)
**Target:** < 240 minutes (4 hours)

---

### Panel 3: False Positive Rate — Metric Tile
```json
{
  "title": "False Positive Rate",
  "type": "metric",
  "formula": "(false_positives / total_alerts) * 100",
  "total_alerts": 108,
  "false_positives": 13,
  "result": "12.0%",
  "target": "< 10%"
}
```

---

### Panel 4: Dwell Time — Bar Chart
```json
{
  "title": "Attacker Dwell Time per Incident",
  "type": "bar",
  "data": [
    {"incident": "INC-2026-0330", "dwell_hours": 6.1},
    {"incident": "INC-2026-0331", "dwell_hours": 3.7},
    {"incident": "INC-2026-0401", "dwell_hours": 3.4}
  ],
  "average_dwell": 4.4,
  "target_line": 2.0
}
```
**Average Dwell:** 4.4 hours
**Target:** < 2 hours

---

### Panel 5: Incident Count by Type — Pie Chart
```json
{
  "title": "Incidents by Type — Week 4",
  "type": "pie",
  "data": [
    {"label": "Phishing",           "value": 1},
    {"label": "Lateral Movement",   "value": 1},
    {"label": "Exploitation",       "value": 1}
  ]
}
```

---

### Panel 6: Alerts by Source IP — Data Table
```json
{
  "title": "Top Source IPs — Week 4",
  "type": "data_table",
  "index": "wazuh-alerts-*",
  "aggregation": "terms",
  "field": "source.ip",
  "size": 10
}
```

| Rank | Source IP   | Alert Count | Top TTP | Status   |
|------|-------------|-------------|---------|----------|
| 1    | 10.0.2.20   | 47          | T1078   | Blocked  |
| 2    | 10.0.2.21   | 8           | T1110   | Monitored|
| 3    | 10.0.2.18   | 3           | T1190   | Cleared  |

---

## Dashboard Access

- **URL:** `http://localhost:5601/app/security`
- **Space:** SOC Week 4
- **Index Pattern:** `wazuh-alerts-*`
- **Time Filter:** 30 March 2026 – 02 April 2026

---

## How to Import Dashboard

1. Open Kibana → Stack Management → Saved Objects
2. Import → Select `soc-week4-dashboard.ndjson`
3. Navigate to Dashboard → SOC Week 4 — Performance Metrics
4. Set date range to: 30 March – 02 April 2026

---

*Dashboard Author: SOC Analyst | cyart-soc-team | 02 April 2026*
