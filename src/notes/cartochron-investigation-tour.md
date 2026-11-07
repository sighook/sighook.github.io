---
title: 'Cartochron: reading recorded locations without inventing movement'
description: A practical synthetic Cartochron walkthrough covering recording runs, gaps, receipt times, route comparisons, and evidence limits.
date: 2026-11-07
note: true
root: ../
page-class: note
---

# Cartochron: reading recorded locations without inventing movement

I built [Cartochron](https://github.com/cartochron/cartochron) to keep
location observations inspectable without quietly turning them into a story
about continuous movement. It stores received positions in SQLite and displays
them on a Leaflet map, with separate recording runs and the provenance needed
to interpret them.

A line on a map is a display of reports. It is not proof that someone
travelled along every metre of the line, or that two recordings which cross
represent a meeting. Here is a way to explore that distinction without using
a real device or collecting anyone's location.

## Run the synthetic investigation

With Python 3 and the project's build prerequisites installed:

```sh
git clone https://github.com/cartochron/cartochron.git
cd cartochron
make demo
```

Open <http://127.0.0.1:8877/>. The demo starts a local receiver with a
temporary SQLite database, synthetic observations, and a prepared example
annotation. It does not connect to a phone or touch an existing recording.
The database is removed when the demo stops. The first run also downloads and
verifies the pinned Leaflet assets if they are not already present.

## First: inspect what the receiver actually knows

In **Monitor**, select an acquisition channel. It follows the newest recording
run associated with that channel, but it does not merge separate runs into
one. A recent receipt says that the receiver obtained a report recently; it
does not establish that a device is currently connected or that the reported
position was measured at the same time.

Switch to **History** and open `demo-oneplus-morning`. The history stays tied
to that run, even when another run appears on the same channel. A gap of more
than ten minutes between received fixes is shown as a break. The viewer must
not fill the unobserved interval with invented travel.

## Second: separate geography from time

Open **Compare routes** and place more than one run on the map. A useful
counterexample is to compare a run that passes through a location with another
recording from a different time. The paths may cross spatially, without the
receipts overlapping at all.

Use **Shared time** to inspect the recorded fixes near the same time. A
candidate fix is shown only while it falls within the tool's five-minute
freshness window; no positions are interpolated. The spatial crossing remains
visible, but its interpretation changes once time is considered.

For a positive *candidate*, compare `demo-oneplus-evening` with
`demo-lg-evening` using **Where did two recordings overlap?**. Inspect the
100-metre / 5-minute witness and its linked example note. The result is a
pair of reported observations close in place and receipt time, not verified
co-presence of physical devices.

## Third: understand the limits of the view

Use **What was here?** to inspect displayed observations near a chosen point.
That operation works against tracks currently loaded in the browser. It is
not a search over every observation in the database. History is paginated,
and partial results remain explicitly marked as partial.

Three distinctions matter throughout the interface:

- **Source or channel versus run:** configured acquisition identities are
  operator assertions; a run is one bounded recording episode.
- **Receipt time versus measurement time:** the server can prove when it
  received a report, not necessarily when a producer measured the position.
- **Observation versus movement:** the route is built from samples; gaps and
  inferred travel remain uncertain.

## From a demonstration to an actual receiver

For persistent, locally held observations, the project documents a SQLite
path and an optional authenticated Docker Compose deployment. Data acquisition
is deliberately separate: the
[GPSD adapter](https://github.com/cartochron/cartochron-gpsd) and
[Metasploit adapter](https://github.com/cartochron/cartochron-metasploit)
submit observations through the receiver's HTTP contract. They do not define
what the map is allowed to infer.

The [investigation walkthrough](https://github.com/cartochron/cartochron/blob/master/docs/walkthrough.md),
[handbook](https://github.com/cartochron/cartochron/blob/master/docs/handbook.md),
and the in-app **Guide** explain the full exercises and the current controls.
The example here needs neither a GPS feed nor a Metasploit session.

The receiver handles sensitive location records. Run it and its adapters only
for devices and investigations you own or are explicitly authorized to
operate; protect recordings, backups, and credentials accordingly.
