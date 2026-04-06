# Section 04 — Adversary Emulation Techniques

## Objective
Simulate real-world adversary TTPs using MITRE Caldera to test SOC detection capabilities, validate Wazuh alerting rules, and identify detection gaps.

---

## Emulation Scope

| Field              | Value                                            |
|--------------------|--------------------------------------------------|
| **Framework**      | MITRE Caldera v4                                 |
| **TTPs Tested**    | T1566 (Phishing), T1078 (Valid Accounts), T1210  |
| **Attacker IP**    | `10.0.2.20`                                      |
| **Target Host**    | 192.168.10.5 (Windows VM — Metasploitable2)      |
| **Date**           | 31 March 2026                                    |
| **SIEM**           | Wazuh                                            |

---

## Operations Run

| Operation ID | TTP    | TTP Name                         | Detection Result |
|--------------|--------|----------------------------------|------------------|
| OP-001       | T1566  | Phishing                         | Detected      |
| OP-002       | T1078  | Valid Accounts                   |  Detected      |
| OP-003       | T1210  | Exploitation of Remote Services  |  Partial       |
| OP-004       | T1059  | Command and Scripting Interpreter|  Detected      |

---

## Full Report → [`emulation-report.md`](./emulation-report.md)

---

## References
- [MITRE Caldera](https://caldera.mitre.org/)
- [MITRE ATT&CK Navigator](https://mitre-attack.github.io/attack-navigator/)
- [Red Canary Emulation Guide](https://redcanary.com/threat-detection-report/)
