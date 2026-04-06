#  Executive Report — SOC Performance Week 4
**Prepared by:** SOC Analyst — cyart-soc-team
**Period:** 30 March 2026 – 02 April 2026
**Classification:** TLP: AMBER (Internal Leadership Only)

---

## Executive Summary

During the week of 30 March to 02 April 2026, the Security Operations Center (SOC) detected and contained a targeted phishing and credential abuse attack originating from IP address `10.0.2.20`. The attacker successfully compromised one user account before being detected and blocked within 6 hours. Our automated response system (SOAR) reduced the blocking response time to under one minute, significantly limiting damage.

Three incidents were handled this week. The team maintained a 100% incident resolution rate within our 24-hour SLA. Key improvement areas identified include faster detection tuning (current detection time: 2 hours; target: under 1 hour) and reducing attacker dwell time. Immediate steps have been taken including multi-factor authentication enforcement and updated filtering rules. A phishing simulation exercise is scheduled for all staff within 30 days to reduce human risk exposure.

**Bottom line:** The SOC performed effectively under real attack conditions. Automation is working as designed. Two focused improvements — faster detection and reduced dwell time — will be completed within the next 30 days.

---

## Incident Snapshot

| Incident ID   | Type                    | Severity | Detected    | Resolved    | Outcome     |
|---------------|-------------------------|----------|-------------|-------------|-------------|
| INC-2026-0330 | Phishing / Priv. Escalation | High | 30 Mar 09:14| 30 Mar 13:20| Contained   |
| INC-2026-0331 | Lateral Movement (SMB)  | Medium   | 31 Mar 10:20| 31 Mar 14:00| Contained   |
| INC-2026-0401 | Samba Exploit Attempt   | High     | 01 Apr 08:05| 01 Apr 11:30| Blocked     |

---

## Key Performance Metrics (Week of 30 Mar – 02 Apr 2026)

| Metric                  | This Week  | Target    | Trend        |
|-------------------------|------------|-----------|--------------|
| Mean Time to Detect     | 2 hours    | < 1 hour  |  Improving |
| Mean Time to Respond    | 2h 6 min   | < 4 hours |  Met       |
| Dwell Time (avg)        | 6 hours    | < 2 hours |  Above target |
| False Positive Rate     | 12.0%      | < 10%     |  Improving |
| Incidents Resolved      | 3/3 (100%) | > 95%     |  Met       |
| Automation Response     | 47 seconds | < 5 min   |  Excellent |

---

## Top Risks This Week

| Risk                            | Likelihood | Impact | Action Taken                         |
|---------------------------------|------------|--------|--------------------------------------|
| User credential compromise      | High       | High   | MFA enforcement initiated            |
| SMB lateral movement            | Medium     | High   | Network segmentation review started  |
| Email filtering gaps            | High       | Medium | Threat intel feed integration in progress |

---

## Recommendations for Leadership

| Priority | Recommendation                                      | Timeline  |
|----------|-----------------------------------------------------|-----------|
| 1        | Enforce MFA for all domain accounts                 | 7 days    |
| 2        | Reduce MTTD to < 1 hour via Wazuh rule tuning       | 30 days   |
| 3        | Launch company-wide phishing simulation             | 30 days   |
| 4        | Implement network micro-segmentation                | 60 days   |
| 5        | Integrate automated threat intel with email gateway | 30 days   |

---

*Report prepared by SOC Analyst | cyart-soc-team | 02 April 2026*
*Distribution: SOC Manager, CISO, IT Leadership*
