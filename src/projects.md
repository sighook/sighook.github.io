---
title: Projects --- Alexandr Savca
---

# Projects

Selected systems engineering, security research tooling, and earlier
experimental work.

---

## Systems Engineering

### Zeppe-Lin

Source-based GNU/Linux distribution and ongoing systems engineering
project derived from CRUX. The native package stack is decomposed into
contract-oriented components separating execution, application, durable
state, resolution, reconciliation, and platform mechanisms.

Representative current work:

- [libpkgexec-linux](https://github.com/zeppe-lin/libpkgexec-linux) ---
  Linux execution backends with explicit isolation and resource contracts
- [libpkgapply](https://github.com/zeppe-lin/libpkgapply) and
  [libpkgapply-posix](https://github.com/zeppe-lin/libpkgapply-posix) ---
  application, recovery, and POSIX mutation mechanisms
- [pkgctl](https://github.com/zeppe-lin/pkgctl) --- package control plane
  composing the native package-management boundaries
- [zeppe-lin-system](https://github.com/zeppe-lin/zeppe-lin-system) ---
  product composition and bootstrap

<https://github.com/zeppe-lin>

---

## Security Research & Tooling

### Pixload

Payload injection toolkit for image formats (JPEG, PNG, GIF, BMP,
WebP).

- Embeds arbitrary payloads into image structures
- Useful for testing parser behavior and detection systems

The repository has about 1,300 stars and 250 forks on GitHub (August
2026).

<https://github.com/sighook/pixload>

### pdf2hashcat

Maintained Python utility for extracting hashcat-compatible hashes from
encrypted PDF files.

- Supports PDF 1.1 through 1.7, including standard and AES encryption
- Pure Python 3 with unit tests

<https://github.com/sighook/pdf2hashcat>

### layer234-attack-tools

Utilities for OSI layers 2---4.

- Network-level attacks and testing primitives
- Packet manipulation and protocol interaction

<https://github.com/sighook/layer234-attack-tools>

### layer567-attack-tools

Utilities for OSI layers 5---7.

- Application-layer attack tooling
- Protocol fuzzing and interaction helpers

<https://github.com/sighook/layer567-attack-tools>

---

## Writing

### The Fieldbook

*Applied Cybernetic Necromancy in Haunted Infrastructure.*

A technical book on systems failure analysis: semantic authority,
contracts and invariants, boundary failure, artifact truth, semantic
drift, institutional memory, intervention, verification, and repair.

<https://github.com/zeppe-lin/fieldbook>

---

## Earlier Work

Older security research utilities and experimental projects retained as
part of the public record.

### captal

Security auditing and social engineering framework.

- Wi-Fi attacks, MITM, phishing scenarios
- Layer 2 attack simulations
- Research-oriented tooling

<https://github.com/sighook/captal>

### wxp78key

Tiny keylogger for XP/Vista/7/8 with FTP upload.

<https://github.com/sighook/wxp78key>

### asleap (extended)

Enhanced LEAP attack implementation.

- Corrected attack logic
- Added MSCHAPv2 verification
- Configurable bruteforce support

<https://github.com/sighook/asleap>

### gencc

Credit card number generator (Luhn-valid).

- Useful for testing validation systems

<https://github.com/sighook/gencc>

### sms (deprecated)

Research project on SMS submission via web portals.

- Included captcha bypass analysis
- Retained for educational reference

<https://github.com/sighook/sms>
