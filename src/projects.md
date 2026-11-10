---
title: Projects --- Alexandr Savca
description: Selected source code and documentation for security tooling and systems software.
---

# Projects

A few projects I have built, adapted, or maintained. The repositories have
implementation details and tests; this page is just a short selection.

## Cartochron

A Python/SQLite receiver and Leaflet map for investigating recorded location
observations in authorized research. It keeps runs, receipt times, and gaps
distinct, with
history searches and cross-run comparisons.

[Source and documentation](https://github.com/cartochron/cartochron) ·
[Synthetic walkthrough](notes/cartochron-investigation-tour.html) ·
[GPSD adapter](https://github.com/cartochron/cartochron-gpsd) ·
[Metasploit adapter](https://github.com/cartochron/cartochron-metasploit)

## Pixload

Tools for constructing image files with embedded payloads, useful for testing
file-upload handling, content inspection, and parser assumptions. Supports
BMP, GIF, JPEG, PNG, and WebP.

[Source](https://github.com/sighook/pixload)

## nmap-extra-nse

Two independently maintained Nmap NSE scripts for offline IP and traceroute
geolocation, with a Lua GeoLite2 MMDB reader and tests for malformed inputs.
The results retain location uncertainty; these are not official Nmap scripts.

[Source](https://github.com/sighook/nmap-extra-nse) ·
[Technical note](notes/nmap-geolite2.html)

## pdf2hashcat

Python utility for extracting hashcat-compatible hashes from encrypted PDFs,
with support for PDF 1.1--1.7 encryption formats and unit tests. Adapted from
earlier work by Shane Quigley and philsmd; I maintain this version.

[Source](https://github.com/sighook/pdf2hashcat)

## rawmkit

A collection of C/X11 desktop components: window management, an experimental
display manager, session supervision, clipboard history, and password-store
tools. The components have separate responsibilities, with attention to process
lifecycles and security boundaries. `rawm` began as a `dwm` derivative.

[Repositories](https://github.com/rawmkit) ·
[Window manager](https://github.com/rawmkit/rawm) ·
[Display manager](https://github.com/rawmkit/rawmdm)

## Zeppe-Lin

A source-based GNU/Linux project derived from CRUX. My recent work focuses
on the package-management stack: keeping process execution, filesystem
mutation, durable state, and recovery as separate, testable contracts.

[Project repositories](https://github.com/zeppe-lin) ·
[Package control plane](https://github.com/zeppe-lin/pkgctl) ·
[Linux execution backend](https://github.com/zeppe-lin/libpkgexec-linux)
