---
title: The Map Is Not the Router
description: Repairing Nmap's offline geolocation path, a fragile traceroute dependency, and an unusually patient pull request.
date: 2026-11-10
note: true
root: ../
page-class: note
---

# The Map Is Not the Router

I wanted Nmap to read local GeoLite2 databases and put approximate IP locations
on a map. No lookup service, no external API, no network dependency beyond the
scan itself. It sounded modest. Then I read the existing scripts.

## The existing machinery

[Nmap's MaxMind script](https://github.com/nmap/nmap/blob/master/scripts/ip-geolocation-maxmind.nse)
still expects `GeoLiteCity.dat`, the old database format. Modern GeoLite2 files
are `.mmdb`, with different records and a different search tree. The script also
has an IPv6 TODO. Renaming the database would not help; the reader speaks a
different language.

The [GeoPlugin host script](https://github.com/nmap/nmap/blob/master/scripts/ip-geolocation-geoplugin.nse)
uses an external service. So does the
[old traceroute geolocator](https://github.com/nmap/nmap/blob/master/scripts/traceroute-geolocation.nse),
which sends separate HTTP requests to GeoPlugin for its hops. Partway through
my tests, the traceroute geolocator stopped returning useful locations. I did
not isolate whether the service, its response, or the network was responsible.
The traceroute itself wasn't the problem; its commentary had a remote dependency.

The same script exports KML as a `LineString` through those estimated
coordinates. That turns IP geolocation guesses into a line that looks like a
measured physical route. The display has quietly acquired more authority than
the underlying evidence.

Meanwhile, Nmap already has a `geoip` registry and map exporters that consume
coordinates. Those still work. The problem wasn't the whole mapping stack. It
was incompatible data formats, duplicated lookups, and a failure to distinguish
*an estimated location* from *a fact about the route*.

## Fix the boundary

I could have patched the old `.dat` reader, replaced one web service with
another, or rebuilt the map exporters. None addressed the whole problem cleanly.
So I reused an old [nmap-extra-nse](https://github.com/sighook/nmap-extra-nse)
for this purpose:

- A bounded, pure-Lua MMDB reader for IPv4 and IPv6, using City, Country, and
  optional ASN data.

- Two scripts: `ip-geolocation-mmdb.nse` for hosts and
  `traceroute-geolocation-mmdb.nse` for hops.

- One shared lookup interface and explicit error states. Host results publish
  coordinates to Nmap's existing `geoip` registry when available.

No web queries during the scan, and no second mapping framework to maintain.
The data reader owns lookups. Nmap owns scanning. The map does not get a vote
on whether an observation is true.

## Registration is not location

The tests exposed an error in our first pass: a `registered_country` is not a
geographic location. Treating registration as location would put pins on a map
without coordinates to justify them.

In the GeoLite2 snapshot used for testing:

```text
1.1.1.1  registered country: Australia  AS13335 (Cloudflare)
8.8.8.8  location: United States       AS15169 (Google)
         coordinates: 37.75100, -97.82200
         accuracy radius: 1000 km
```

The first record gets no pin. The second has coordinates, with a **1,000 km
accuracy radius**. Useful for orientation; less useful for identifying a
building. In one traceroute, two geolocated hops had 5 km radii and two had
1,000 km; the destination supplied no coordinates.

Our KML exports individual points with their reported radii. It doesn't join
them into a route the scan never measured. That seems a reasonable limit for a
machine whose job is to report evidence rather than manufacture it.

## An open pull request, in geological time

> "Why not send this to Nmap upstream?"

I submitted [PR #718](https://github.com/nmap/nmap/pull/718), an Oracle TNS
poisoning check, on **2 March 2017**. It received serious technical review,
including questions about false positives and packet construction. I answered.
As of November 2026, it is still open.

GitHub has an *open* state. It does not yet have a *sedimentary* state.

That's not a complaint about the reviewers; integrating code upstream takes
care, and nobody owes a patch a merge. But an external review queue isn't a
release schedule. The new geolocation code therefore has its own maintained
repository. Older Nmap PR snapshots live separately in `contrib/` and
`archive/`, where they can be inspected without pretending they're an
installable suite.

## Evidence of life

We compared selected IPv4 and IPv6 results against `mmdblookup`. In Nmap
7.991, host lookups, ASN enrichment, IPv4 traceroute annotation, and KML export
worked. Four Lua suites test the reader, provider, NSE output, malformed input,
and file cleanup. A 256-address batch completed without NSE errors. That is a
set of checks, not a guarantee about every database or network.

```sh
git clone https://github.com/sighook/nmap-extra-nse.git
cd nmap-extra-nse
make check
make fetch
sudo make install
```

Setup, database licensing, and scan examples are in the
[README](https://github.com/sighook/nmap-extra-nse#readme).
[`v0.1`](https://github.com/sighook/nmap-extra-nse/tree/v0.1) is released.

The database estimates locations. Traceroute measures hops. The map can show
both, provided it doesn't confuse one for the other.
