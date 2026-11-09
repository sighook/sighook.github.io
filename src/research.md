---
title: Research --- Alexandr Savca
description: Published vulnerability disclosures, Kismet security fixes, and upstream protocol and systems contributions.
---

# Research

Security findings and upstream engineering, with links to the public
record.

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

My Oracle TNS work grew out of professional deep packet inspection (DPI)
development in 2016–2017. I reverse-engineered parts of the TNS/SQL\*Net
wire protocol from packet captures, then contributed the resulting protocol
knowledge and dissector improvements upstream to Wireshark. The changes
made more of the SQL\*Net/Net8 and OCI exchanges readable, beyond identifying
the outer packet type:

- **DATA messages:** [SQL*Net function IDs and OCI subfunctions](https://github.com/wireshark/wireshark/commit/4f684a606226bee6381285388e3b28f06975f1f4),
  followed by [Set Protocol request and partial response dissection](https://github.com/wireshark/wireshark/commit/cd4540b260040f08a5e814fab4c60e001501f8cb).
- **Framing and negotiation:** [Oracle 12c packet-length handling](https://github.com/wireshark/wireshark/commit/104b1029486e3a656c9abefa733bc038563afa43)
  and [SNS version and services fields](https://github.com/wireshark/wireshark/commit/031db50c64995d0879b77570f562c0eb98d52e4a).
- **Session setup:** [OPI Version2 response parsing](https://github.com/wireshark/wireshark/commit/f27734f3a2747a150a6bc4d22bb2d212a8322c63)
  and [session-key and authentication parameter fields](https://github.com/wireshark/wireshark/commit/9b008282c4ee79c696d435a42af7243c20482a40).

Other dissector fixes include [PCEP XRO length handling](https://github.com/wireshark/wireshark/commit/89076e6a5d7f44d9cd2ce0f38ba359417091df26)
and [undefined signed shifts](https://github.com/wireshark/wireshark/commit/b545c60658143a730619df7b6c6f6df2f22e6398).

Smaller contributions include a [touchpad hardware ID](https://github.com/torvalds/linux/commit/8938fc7b8fe9ccfa11751ead502a8d385b607967)
for Linux and [C/documentation fixes](https://github.com/Perl/perl5/commits?author=sighook)
for Perl 5.

For investigation notes and experimental work, see
[Notes](notes.html) ([RSS](feed.xml)).
