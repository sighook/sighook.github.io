---
title: Four security fixes in Kismet 2026-10-R1
description: Notes on four Kismet fixes involving PPI GPS parsing, HTTP path containment, stalled requests, and Radiotap bounds.
date: 2026-11-07
note: true
root: ../
page-class: note
---

# Four security fixes in Kismet 2026-10-R1

I spent part of October reviewing Kismet's packet parsers and HTTP handling.
Four issues from that work were fixed upstream and shipped in
[Kismet 2026-10-R1](https://kismetwireless.net/posts/kismet-2026-10-r1/),
released on 29 October 2026. This is a record of the failure conditions and
of what the fixes establish. It isn't a claim that every issue has a CVE.

The common theme is simple: a bound or identity established at one level of a
system must not be mistaken for the bound or identity of the object inside it.

## PPI GPS: the field has its own length

A packet's capture-buffer length, its PPI header length, an individual PPI
field's length, and the inner GPS structure's declared length are different
limits. The parser previously mixed those limits. In malformed input, an inner
length could underflow or the parser could read GPS data beyond its declared
field, despite the outer packet still having bytes available.

The fix checks the minimum header lengths, requires every field to fit in the
remaining PPI header, validates the GPS substructure, and checks remaining
bytes before reading coordinate components. Valid GPS fields still decode.

[Upstream fix: `0291935`](https://github.com/kismetwireless/kismet/commit/0291935fb31c0e01e7c87e201cef621910109d9c)

## HTTP static files: a prefix is not containment

The HTTP server's static-file handling could accept a request with `..` that
resolved into a *sibling* directory whose name began with the configured web
root's name. A string prefix matched, but the resolved file was outside the
intended root. This was a constrained path-traversal issue (CWE-22), not a
claim that every arbitrary filesystem path was reachable.

The fix requires the requested file to remain inside the actual web-root
directory, rather than merely sharing a filename prefix with it.

[Upstream fix: `a2f096a`](https://github.com/kismetwireless/kismet/commit/a2f096aa2fa4e298d80eebaf074d251b915069d6)

## HTTP request lifecycle: an incomplete request still costs a thread

A client that sent an incomplete HTTP request, or sent it very slowly, could
keep a server thread occupied without completing useful work. This is a
resource-lifetime problem: the connection had an owner, but its lifetime was
not sufficiently bounded by request progress.

The upstream change disconnects stalled and slow requests after 30 seconds.
It bounds how long one such request can occupy a thread; it should not be
read as a general proof that the server cannot be exhausted under load.

[Upstream fix: `21c1107`](https://github.com/kismetwireless/kismet/commit/21c1107f196efc1121376bfaa801968f4635e4a5)

## Radiotap: extension bitmaps stop at the Radiotap header

Radiotap headers can have additional presence bitmaps. When the advertised
header was malformed, walking those extension words could run beyond the
header's declared end. A packet may contain more bytes after that header;
those bytes do not make them valid Radiotap metadata.

The fix rejects headers that are too short and stops extension-bitmap parsing
at the declared Radiotap boundary.

[Upstream fix: `3026ae0`](https://github.com/kismetwireless/kismet/commit/3026ae04d3141c195e89d14a74579ddef1f9db03)

## Status and evidence

These four changes are present in the
[`kismet-2026-10-R1` tag](https://github.com/kismetwireless/kismet/tree/kismet-2026-10-R1).
The release notes explicitly call out the static-root issue and PPI GPS
parsing; the HTTP timeout and Radiotap hardening are also covered in the
release's security fixes. The associated commits retain the individual change
history and authorship.

I have not listed CVE identifiers or CVSS scores for these findings. None
has been established here, and the affected historical version range has not
been pinned down. The release tag and individual fixes are the useful,
verifiable references for now.

What I find interesting is not a spectacular exploit chain. It is the same
failure pattern in several places: a parser trusts the wrong length, a path
check trusts the wrong prefix, or a connection survives without a meaningful
progress bound. These are small boundary mistakes, but they define what the
rest of the system is allowed to believe.
