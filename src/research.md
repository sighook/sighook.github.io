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

### Wireshark — Oracle TNS and dissector fixes

Most of my Wireshark work began with Oracle TNS (2016–2017): making more
of the SQL*Net/Net8 and OCI exchanges readable in packet captures, beyond
identifying the outer packet type. The main changes were:

- **DATA messages:** [SQL*Net function IDs and OCI subfunctions](https://github.com/wireshark/wireshark/commit/4f684a606226bee6381285388e3b28f06975f1f4),
  followed by [Set Protocol request and partial response dissection](https://github.com/wireshark/wireshark/commit/cd4540b260040f08a5e814fab4c60e001501f8cb).
- **Framing and negotiation:** [Oracle 12c packet-length handling](https://github.com/wireshark/wireshark/commit/104b1029486e3a656c9abefa733bc038563afa43)
  and [SNS version and services fields](https://github.com/wireshark/wireshark/commit/031db50c64995d0879b77570f562c0eb98d52e4a).
- **Session setup:** [OPI Version2 response parsing](https://github.com/wireshark/wireshark/commit/f27734f3a2747a150a6bc4d22bb2d212a8322c63)
  and [session-key and authentication parameter fields](https://github.com/wireshark/wireshark/commit/9b008282c4ee79c696d435a42af7243c20482a40).

Later patches (2018) covered [PCEP XRO length handling](https://github.com/wireshark/wireshark/commit/89076e6a5d7f44d9cd2ce0f38ba359417091df26),
[NetMon link-speed formatting](https://github.com/wireshark/wireshark/commit/40de0010bb302a8dedd3d4ad6aa75da8f27a297c),
and [undefined signed shifts found by cppcheck](https://github.com/wireshark/wireshark/commit/b545c60658143a730619df7b6c6f6df2f22e6398)
across several dissectors. Smaller maintenance changes addressed
[cppcheck HTML output](https://github.com/wireshark/wireshark/commit/dfb92c2a1d200f777322f532e377bfd8eb1865a8),
[conditional macro syntax](https://github.com/wireshark/wireshark/commit/ec0f8e6c36f16ca0f7eeb712f823f857468ff6d9),
and [redundant `break` statements](https://github.com/wireshark/wireshark/commit/993b47eb400e9a9aa79e22f9fb0fc5da4e45f978).
A separate [TNS Refuse note](https://github.com/wireshark/wireshark/commit/cca3c926c8256d4573d1b6ddb0e24f46220bba57)
recorded an unverified observation for future investigation; it did not
implement additional parsing.

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
