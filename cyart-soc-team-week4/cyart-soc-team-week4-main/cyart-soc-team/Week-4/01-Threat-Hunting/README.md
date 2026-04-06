# Section 01 — Threat Hunting

## Objective
Proactively identify threats using hypothesis-driven hunting against SOC log data, leveraging MITRE ATT&CK technique T1078 (Valid Accounts) as the primary hunting hypothesis.

---

## Methodology Used: TaHiTI + SqRR

| Phase       | Description                                               |
|-------------|-----------------------------------------------------------|
| **Search**  | Define hypothesis; identify relevant data sources         |
| **Query**   | Build log queries in Elastic Security / Velociraptor      |
| **Retrieve**| Pull matching events; filter false positives              |
| **Respond** | Document and escalate confirmed threats                   |

---

## Hypothesis

> **"Unauthorized privilege escalation is occurring via Valid Accounts (T1078) — specifically, domain accounts are being assigned unexpected administrative roles."**

**Supporting Intelligence:** AlienVault OTX IOC feed flagged suspicious IPs matching patterns of credential abuse.

---

## Data Sources

| Source              | Tool              | Events Queried       |
|---------------------|-------------------|----------------------|
| Windows Event Logs  | Elastic Security  | Event ID 4672, 4624  |
| Process Data        | Velociraptor      | SELECT * FROM processes |
| Network Traffic     | Wazuh             | Outbound connections |
| Threat Intel        | AlienVault OTX    | T1078 IOC feed       |

---

## Steps Performed

### Step 1 — Environment & Tool Verification
- Confirmed Elastic Security indexing Windows event logs from target host
- Verified AlienVault OTX connectivity
- Configured Velociraptor agent on Windows VM

### Step 2 — Hypothesis Query (Elastic Security)
```json
{
  "query": {
    "bool": {
      "must": [
        { "match": { "event.code": "4672" }},
        { "range": { "@timestamp": {
            "gte": "2026-03-30T00:00:00",
            "lte": "2026-04-02T23:59:59"
        }}}
      ]
    }
  }
}
```

### Step 3 — Velociraptor Process Hunt
```sql
SELECT Name, Pid, Ppid, CommandLine, Username
FROM processes
WHERE Username LIKE '%admin%' OR CommandLine LIKE '%net user%'
```

### Step 4 — AlienVault OTX IOC Cross-Reference
- Searched pulse for T1078 indicators
- Cross-referenced suspicious IPs with Wazuh network logs
- Confirmed `10.0.2.20` appeared in OTX as a known threat actor lateral movement source

---

## Findings

See full report → [`threat-hunting-report.md`](./threat-hunting-report.md)

---

## References
- [MITRE ATT&CK T1078](https://attack.mitre.org/techniques/T1078/)
- [SANS Threat Hunting Papers](https://www.sans.org/reading-room/)
- [Elastic Threat Hunting Guide](https://www.elastic.co/security-labs/)
- [TaHiTI Framework](https://www.betaalvereniging.nl/wp-content/uploads/TaHiTI-Threat-Hunting-Methodology.pdf)
