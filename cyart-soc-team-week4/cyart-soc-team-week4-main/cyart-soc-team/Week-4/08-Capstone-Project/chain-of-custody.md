#  Chain of Custody — Evidence Log
**Incident:** INC-2026-0401
**Analyst:** SOC Analyst — cyart-soc-team
**Start Date:** 01 April 2026
**Classification:** TLP: AMBER

---

## Chain of Custody Purpose

This document records all digital evidence collected during the investigation of incident INC-2026-0401. It ensures evidence integrity, tracks custody transfers, and maintains admissibility standards.

---

## Evidence Items

| Item # | Item ID       | Description                          | Source Host    | Collected By | Date/Time (UTC)         | Hash Algorithm | Hash Value (placeholder)                              |
|--------|---------------|--------------------------------------|----------------|--------------|-------------------------|----------------|-------------------------------------------------------|
| 1      | EVD-001       | Wazuh Alert Log — 01 Apr 2026        | Wazuh Server   | SOC Analyst  | 2026-04-01 08:10:00 UTC | SHA256         | `[SHA256_HASH_01_INSERT_ACTUAL_VALUE]`                |
| 2      | EVD-002       | Network Packet Capture (PCAP)        | 192.168.10.5   | SOC Analyst  | 2026-04-01 08:15:00 UTC | SHA256         | `[SHA256_HASH_02_INSERT_ACTUAL_VALUE]`                |
| 3      | EVD-003       | Windows Event Log Export (EVTX)      | 192.168.10.5   | SOC Analyst  | 2026-04-01 08:20:00 UTC | SHA256         | `[SHA256_HASH_03_INSERT_ACTUAL_VALUE]`                |
| 4      | EVD-004       | Velociraptor Process Dump            | 192.168.10.5   | SOC Analyst  | 2026-04-01 08:25:00 UTC | SHA256         | `[SHA256_HASH_04_INSERT_ACTUAL_VALUE]`                |
| 5      | EVD-005       | Metasploit Session Log               | Kali (10.0.2.20)| SOC Analyst | 2026-04-01 09:00:00 UTC | SHA256         | `[SHA256_HASH_05_INSERT_ACTUAL_VALUE]`                |
| 6      | EVD-006       | Disk Image — Metasploitable2 (FTK)   | 192.168.10.5   | SOC Analyst  | 2026-04-01 09:30:00 UTC | SHA256         | `[SHA256_HASH_06_INSERT_ACTUAL_VALUE]`                |
| 7      | EVD-007       | TheHive Case Export (TH-2026-0401)   | TheHive Server | SOC Analyst  | 2026-04-01 11:45:00 UTC | SHA256         | `[SHA256_HASH_07_INSERT_ACTUAL_VALUE]`                |
| 8      | EVD-008       | Elastic Security Alert Export (CSV)  | Elastic Server | SOC Analyst  | 2026-04-02 08:00:00 UTC | SHA256         | `[SHA256_HASH_08_INSERT_ACTUAL_VALUE]`                |

> **Note:** Replace placeholder hash values with actual SHA256 hashes generated during collection.
> ```bash
> sha256sum <filename>   # Linux
> Get-FileHash <file> -Algorithm SHA256  # Windows PowerShell
> ```

---

## Hash Verification Commands

```bash
# Generate SHA256 for Wazuh log
sha256sum wazuh-alert-log-01apr2026.json

# Generate SHA256 for PCAP
sha256sum network-capture-01apr2026.pcap

# Generate SHA256 for Windows Event Log
sha256sum windows-eventlog-01apr2026.evtx

# Verify disk image integrity
sha256sum metasploitable2-disk.img
```

---

## Custody Transfer Log

| Transfer # | From          | To              | Date/Time (UTC)         | Reason                    | Signature |
|------------|---------------|-----------------|-------------------------|---------------------------|-----------|
| 1          | SOC Analyst   | Evidence Storage| 2026-04-01 12:00:00 UTC | Secure storage after collection | SOC-01 |
| 2          | Evidence Storage | SOC Lead     | 2026-04-02 09:00:00 UTC | Review for reporting      | SOC-01    |
| 3          | SOC Lead      | Archive         | 2026-04-02 17:00:00 UTC | Post-incident archiving   | SOC-Lead  |

---

## Evidence Storage Location

| Location           | Type             | Access Control          |
|--------------------|------------------|-------------------------|
| `/evidence/INC-2026-0401/` | Local Secure Storage | SOC Analyst + SOC Lead only |
| GitHub Repo (hashed refs) | Version Control  | Private repo — team only |

---

## Integrity Statement

I certify that all evidence listed in this document was collected using forensically sound methods, has been hashed to verify integrity, and has been maintained under controlled access throughout the investigation of incident INC-2026-0401.

**Analyst:** SOC Analyst — cyart-soc-team
**Date:** 02 April 2026

---

*Chain of Custody | INC-2026-0401 | cyart-soc-team | 2026*
