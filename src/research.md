---
title: Research --- Alexandr Savca
description: Published vulnerability disclosures, Kismet security fixes, and upstream protocol and systems contributions.
---

# Research

Security findings and upstream engineering, with links to the public
record. A disclosed vulnerability, an accepted fix, and an experimental
patch are different outcomes; I keep them separate here.

## Kismet: four upstream security fixes (2026)

My review resulted in four fixes shipped in
[Kismet 2026-10-R1](https://kismetwireless.net/posts/kismet-2026-10-r1/):

- PPI: check field lengths before decoding GPS and radio data.
- HTTP: keep requests inside the configured web root.
- HTTP: disconnect stalled and slow requests instead of retaining a thread.
- Radiotap: reject malformed headers and extension bitmaps.

The [research note](notes/kismet-2026-security-fixes.html) links the
individual upstream commits and explains the failure conditions. No CVE
identifiers are asserted for these four fixes.

## Published vulnerabilities {#vulnerability-research-cve}

| Identifier | Component | Finding / public record |
|---|---|---|
| [CVE-2020-36420](https://nvd.nist.gov/vuln/detail/CVE-2020-36420) | Polipo | Reachable assertion while parsing malformed HTTP Range headers with `NDEBUG` omitted. |
| [CVE-2021-38614](https://nvd.nist.gov/vuln/detail/CVE-2021-38614) | Polipo | Heap buffer overflow in HTTP Range handling with `NDEBUG` enabled. |
| [CVE-2021-31799](https://www.ruby-lang.org/en/news/2021/05/02/os-command-injection-in-rdoc/) | Ruby RDoc | Command execution through a crafted filename when generating documentation. |
| [CVE-2021-31810](https://www.ruby-lang.org/en/news/2021/07/07/trusting-pasv-responses-in-net-ftp/) | Ruby Net::FTP | A malicious PASV response can redirect connections to another host. |
| [CVE-2021-32066](https://www.ruby-lang.org/en/news/2021/07/07/starttls-stripping-in-net-imap/) | Ruby Net::IMAP | Unexpected STARTTLS responses could leave a connection unencrypted. |

The Ruby links lead to upstream advisories with affected versions and
remediation guidance. Polipo was already unmaintained; its entries link to
the public CVE records, not to a claimed upstream fix.

## Upstream engineering {#upstream-engineering}

### Wireshark — Oracle TNS

Contributions to Oracle TNS dissection, including DATA and Set Protocol
handling, Oracle 12c packet lengths, SNS messages, and authentication and
session-key parsing. The work was aimed at making more of the protocol
visible in packet captures.

### Linux kernel

Added the ELAN0618 ACPI ID for the Lenovo V330-15IKB touchpad to the
`elan_i2c` driver ([upstream commit](https://github.com/torvalds/linux/commit/8938fc7b8fe9ccfa11751ead502a8d385b607967)).

### Perl and other accepted patches

Contributed C and documentation fixes to Perl 5; listed in upstream
`AUTHORS` ([commit history](https://github.com/Perl/perl5/commits?author=sighook)).
Other accepted fixes include
[XMRig](https://github.com/xmrig/xmrig/pull/559),
[zlog](https://github.com/HardySimpson/zlog/pull/106), and
[XSStrike](https://github.com/s0md3v/XSStrike/pull/197).

## Submitted and experimental work

Nmap work includes an Oracle TNS poisoning detection NSE script,
version-detection fixes, and experimental scripts. I have also submitted
an Aircrack-ng patch for manufacturer identification in client listings.
These are not listed above as accepted upstream work.

For longer accounts of investigations and their limits, see
[Notes](notes.html) ([RSS](feed.xml)).
