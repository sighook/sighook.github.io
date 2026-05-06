---
title: Research --- Alexandr Savca
---

# Research

This page summarizes vulnerability research, protocol analysis, and
upstream contributions.
The focus is on practical findings, correctness improvements, and
integration into widely used tools.

---

## Vulnerability Research (CVE)

| CVE | Vector | Summary |
|---|---|---|
| CVE-2020-36420 | Remote | Polipo denial of service via malformed HTTP Range header |
| CVE-2021-38614 | Remote | Polipo heap buffer overflow in Range handling |
| CVE-2021-31799 | Local | Ruby RDoc command injection via crafted filenames |
| CVE-2021-31810 | Remote | Ruby Net::FTP PASV response abuse (connection redirection / scanning) |
| CVE-2021-32066 | MITM | Ruby Net::IMAP STARTTLS stripping due to improper failure handling |

---

## Protocol Analysis & Wireshark Contributions

Work focused on reverse engineering and improving Oracle TNS protocol
support in Wireshark.

### Highlights

- Added DATA message dissection helpers
- Implemented Set Protocol parsing
- Fixed Oracle 12c packet length handling
- Added SNS message parsing (Version, Services)
- Extended authentication and session key handling
- Static analysis cleanup

This work improved correctness and visibility of TNS traffic in
real-world analysis scenarios.

---

## Linux Kernel Contribution

- Input: `elan_i2c` --- added support for ELAN0618 (Lenovo V330-15IKB)

[Additional work](https://github.com/sighook/lwpp) includes custom
kernel patches for wireless security testing and device-specific
kernel modifications.

---

## Tooling Contributions

### Nmap

- NSE script for Oracle TNS poisoning detection
- Fixes for TNS version detection
- Additional experimental NSE scripts

### Aircrack-ng

- Patch adding manufacturer identification to client listings

---

## Notes

Most work here originates from practical research: protocol behavior
under edge conditions, real attack surfaces, and toolchain gaps
discovered during testing.
