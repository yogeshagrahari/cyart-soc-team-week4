# Post-Incident Analysis — Root Cause Analysis Report
**Incident ID:** INC-2026-0330
**Analyst:** SOC Analyst — cyart-soc-team
**Date of Analysis:** 31 March 2026
**Incident Type:** Phishing / Privilege Escalation
**Attacker IP:** `10.0.2.20`

---

## 1. Incident Summary

On 30 March 2026 at 07:14 AM, threat actor using IP `10.0.2.20` conducted a phishing campaign targeting internal users. One user (`testuser`) clicked a malicious link, leading to credential compromise and subsequent privilege escalation (T1078). The incident was detected at 09:14 AM, contained by 11:20 AM, and fully resolved by 01:20 PM on the same day.

---

## 2. Incident Timeline

| Time (30 Mar 2026) | Event                                                      |
|--------------------|------------------------------------------------------------|
| 07:14 AM           | Phishing email received by `testuser` from 10.0.2.20       |
| 07:22 AM           | User clicked malicious link — credentials submitted        |
| 07:23 AM           | Attacker obtained valid credentials for `testuser`         |
| 07:30 AM           | Attacker logged in via SMB (Event ID 4624)                 |
| 09:14 AM           | Wazuh triggered Alert: Unexpected privilege escalation     |
| 09:30 AM           | SOC Analyst assigned — INC-2026-0330 opened                |
| 09:47 AM           | VirusTotal confirmed 10.0.2.20 as malicious                |
| 10:05 AM           | CrowdSec blocked 10.0.2.20                                 |
| 10:15 AM           | `testuser` account locked; password reset initiated        |
| 11:20 AM           | All attacker sessions terminated; lateral movement blocked |
| 01:20 PM           | Incident resolved; monitoring period started               |

---

## 3. Root Cause Analysis — 5 Whys

**Problem Statement:** A phishing attack from 10.0.2.20 successfully compromised user credentials and led to privilege escalation.

| # | Question                                          | Answer                                                         |
|---|---------------------------------------------------|----------------------------------------------------------------|
| 1 | **Why was the phishing email opened?**            | The user `testuser` received a convincing spoofed email        |
| 2 | **Why was the spoofed email not caught?**         | Email filtering rules were not updated with latest phishing patterns |
| 3 | **Why were filtering rules not updated?**         | No automated threat intel feed was integrated with email gateway |
| 4 | **Why was threat intel not integrated?**          | No documented process existed for updating email filtering rules periodically |
| 5 | **Why was there no update process?**              | SOC runbooks lacked a defined email security maintenance schedule |

**Root Cause:** Absence of an automated threat intelligence integration with the email gateway and lack of a documented maintenance schedule for email filtering rules.

---

## 4. Fishbone Diagram — Contributing Factors

```
                        PHISHING BREACH (Effect)
                               |
    ┌──────────────────────────┼──────────────────────────┐
    │                          │                          │
TECHNOLOGY               PROCESS                     PEOPLE
    │                          │                          │
    ├─ No threat intel         ├─ No email filter         ├─ Insufficient
    │  feed integration        │  update process          │  security awareness
    │                          │                          │  training
    ├─ Email gateway           ├─ No periodic             │
    │  rules outdated          │  phishing drills         ├─ User clicked link
    │                          │                          │  without verification
    |- No MFA on               |- Slow alert              |
       user accounts           escalation workflow        |-- No report culture
                                                            for suspicious emails

ENVIRONMENT                                         MEASUREMENT
    │                                                    │
    ├─ External IP not                                   ├─ MTTD too high
    │  pre-blocked                                       │  (2 hours)
    │                                                    │
    └─ Flat network                                      └─ No KPI for
       (no segmentation)                                    email threats
```

---

## 5. Lessons Learned

| #  | Lesson                                              | Recommended Action                                    | Priority | Owner         |
|----|-----------------------------------------------------|-------------------------------------------------------|----------|---------------|
| 1  | Email filtering rules were not current              | Integrate OTX/MISP feed with email gateway            | Critical | Security Eng  |
| 2  | No MFA on domain accounts                           | Enforce MFA for all domain accounts within 30 days    | Critical | IT Admin      |
| 3  | MTTD was 2 hours (07:14 → 09:14)                    | Tune Wazuh rules for earlier privilege detection      | High     | SOC Lead      |
| 4  | No user phishing simulation program                 | Schedule quarterly phishing simulation exercises      | High     | SOC Manager   |
| 5  | Lateral movement not immediately detected           | Enable network segmentation and lateral movement rules| High     | Network Eng   |
| 6  | No automated IP threat feed in email gateway        | Deploy automated threat intel feed integration        | Medium   | Security Eng  |
| 7  | Users do not report suspicious emails               | Launch security awareness campaign                    | Medium   | HR / Security |

---

## 6. Improvement Actions

### Immediate (0–7 days)
- [x] Block `10.0.2.20` at perimeter
- [x] Lock compromised accounts; force password reset
- [ ] Enable MFA for all domain admin accounts
- [ ] Update Wazuh rules for T1078 detection

### Short-term (7–30 days)
- [ ] Integrate AlienVault OTX feed with email gateway
- [ ] Conduct phishing simulation for all staff
- [ ] Update SOC runbook with email filter maintenance schedule

### Long-term (30–90 days)
- [ ] Implement network micro-segmentation
- [ ] Build MTTD/MTTR improvement plan targeting <1 hour MTTD
- [ ] Quarterly threat hunting exercises

---

*Report Author: SOC Analyst | cyart-soc-team | 31 March 2026*
