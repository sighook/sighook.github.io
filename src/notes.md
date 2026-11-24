---
title: Notes --- Alexandr Savca
description: Technical notes on vulnerability research, systems engineering, and experiments.
---

# Notes

Technical notes from source review, investigations, and building things.
These are longer accounts of *what I observed, what I checked, and what the
result actually establishes*, rather than a list of claims or product updates.

Subscribe via [RSS](feed.xml).

## 2026

- **24 November** — [Local AI-Assisted Security Lab with Kali, Metasploit, Goose, and Limonade](notes/lemonade-goose-mcp-kali-msf.html).
  How to deploy a hardened, read-only Kali and Metasploit container and connect both MCP servers to Goose over STDIO backed by a local Lemonade LLM.

- **24 November** — [Local AI-Assisted Traffic Analysis with OWASP ZAP, MCP, Goose, and Lemonade](notes/lemonade-goose-mcp-zap.html).
  How to build a 100% local AI-assisted traffic analysis pipeline by connecting OWASP ZAP's MCP server to Goose and a local Lemonade LLM instance.

- **10 November** — [The Map Is Not the Router](notes/nmap-geolite2.html).
  Offline GeoLite2, a fragile traceroute dependency, and a very old open PR.

- **7 November** — [Four security fixes in Kismet 2026-10-R1](notes/kismet-2026-security-fixes.html).
  Packet-field boundaries, web-root containment, and stalled HTTP connections.

- **7 November** — [Cartochron: reading recorded locations without inventing movement](notes/cartochron-investigation-tour.html).
  An ant-sized investigation of routes and coincident reports, plus a practical GPSD recording setup.

- **7 November** — [Wardriving with Kismet and GPSD](notes/wardriving-kismet-gpsd.html).
  A portable Kismet capture setup with GPSD, a spare Android phone, and optional Kismon.
