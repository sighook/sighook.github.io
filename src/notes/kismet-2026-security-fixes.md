---
title: Four security fixes in Kismet 2026-10-R1
description: "Four upstream Kismet fixes: PPI GPS and Radiotap parsing, static-file path containment, and HTTP request timeouts."
date: 2026-11-07
note: true
root: ../
page-class: note
---

# Four security fixes in Kismet 2026-10-R1

While putting together my [Kismet and GPSD wardriving setup](wardriving-kismet-gpsd.html),
I ended up reading Kismet's packet converters and HTTP server. I wanted to
record Wi-Fi observations; a few days later I was arguing with C++ about
which bytes belong to whom.

Four patches from that review made it upstream into
[Kismet 2026-10-R1](https://kismetwireless.net/posts/kismet-2026-10-r1/),
released on 29 October 2026. Here are the bugs and the fixes, without an
imaginary exploit chain attached.

## PPI: the GPS field isn't the whole packet

PPI has an outer packet, its own header, individual fields, and a GPS
structure inside one of those fields. Each has a length. The old decoder
sometimes checked against the captured packet rather than the bytes left
in the particular field it was reading.

A malformed field could make GPS or 802.11 decoding reach outside that
field. The GPS code also subtracted a header size from an insufficient
length, risking unsigned underflow.

The patch checks the outer and inner lengths before reading, including the
802.11 fields, and restores valid PPI GPS decoding. The rest of the packet
isn't spare storage for a short GPS field.

[Upstream patch: `0291935`](https://github.com/kismetwireless/kismet/commit/0291935fb31c0e01e7c87e201cef621910109d9c)

## HTTP static files: the web root has neighbours

Suppose the configured web root is `/srv/kismet-web`, with a sibling directory
named `/srv/kismet-web-old`. Both paths begin with the same string. They are
not the same directory.

The static-file handler resolved paths, but checked containment with a
string-prefix test. A request containing `..` could reach a file in such a
similarly named sibling directory. This was a specific path-traversal issue
(CWE-22), not arbitrary access to every file on the host.

The fix checks the directory boundary after the prefix. A sibling doesn't
become a child just because its name is familiar.

[Upstream patch: `a2f096a`](https://github.com/kismetwireless/kismet/commit/a2f096aa2fa4e298d80eebaf074d251b915069d6)

## HTTP: half a request, one occupied thread

A client could open a connection and send an incomplete HTTP request, or
trickle it in slowly. The server waited for the rest while a thread stayed
busy. The existing timeout wasn't reliably ending that blocking read.

The change uses a timed asynchronous read and disconnects clients whose
request hasn't completed within 30 seconds. It gives that read a deadline;
it doesn't make the server magically immune to every kind of resource
exhaustion.

[Upstream patch: `21c1107`](https://github.com/kismetwireless/kismet/commit/21c1107f196efc1121376bfaa801968f4635e4a5)

## Radiotap: stop at the end of the header

Radiotap uses a declared header length and can chain additional presence
bitmaps. The old bitmap walk could step beyond the declared Radiotap header
when processing a malformed packet.

There might be more captured bytes after the header. They aren't Radiotap
bitmaps. The fix rejects undersized headers and keeps the extension-bitmap
walk within the advertised header length.

[Upstream patch: `3026ae0`](https://github.com/kismetwireless/kismet/commit/3026ae04d3141c195e89d14a74579ddef1f9db03)

## Shipped

All four changes are in the
[`kismet-2026-10-R1` release](https://github.com/kismetwireless/kismet/tree/kismet-2026-10-R1).
The linked commits show exactly what changed. I'm recording accepted fixes
here, not claiming four CVE assignments or a proven exploit chain.

Thanks to Mike for taking the patches upstream and getting them into the
release. It's rather nice when a few evenings reading code end with less
trouble for the next person running it.
