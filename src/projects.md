---
title: Projects --- Alexandr Savca
description: Selected source code and documentation for security tooling and systems software.
---

# Projects

A few projects I have built or maintained. The repositories contain the
implementation, tests, and operating details; this page is a short map.

## Cartochron

A Python/SQLite receiver and Leaflet map for recorded location observations
in authorized investigations. It preserves separate runs, receipt times,
and gaps, with history searches and cross-run comparisons.

[Source and documentation](https://github.com/cartochron/cartochron) ·
[Synthetic walkthrough](notes/cartochron-investigation-tour.html) ·
[GPSD adapter](https://github.com/cartochron/cartochron-gpsd) ·
[Metasploit adapter](https://github.com/cartochron/cartochron-metasploit)

## pdf2hashcat

Python utility for extracting hashcat-compatible hashes from encrypted
PDF documents. Supports PDF 1.1--1.7 encryption formats and has unit tests.

[Source](https://github.com/sighook/pdf2hashcat)

## Pixload

A toolkit for embedding test payloads in JPEG, PNG, GIF, BMP, and WebP
files. Useful when investigating how parsers, upload pipelines, and
content inspection handle image formats.

[Source](https://github.com/sighook/pixload)

## Zeppe-Lin

A source-based GNU/Linux project derived from CRUX. My recent work focuses
on the package-management stack: keeping process execution, filesystem
mutation, durable state, and recovery as separate, testable contracts.

[Project repositories](https://github.com/zeppe-lin) ·
[Package control plane](https://github.com/zeppe-lin/pkgctl) ·
[Linux execution backend](https://github.com/zeppe-lin/libpkgexec-linux)
