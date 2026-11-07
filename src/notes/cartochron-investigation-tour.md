---
title: 'Cartochron: reading recorded locations without inventing movement'
description: A practical Cartochron GPSD setup, with synthetic recordings, route comparisons, and a few curious ants.
date: 2026-11-07
note: true
root: ../
page-class: note
---

# Cartochron: reading recorded locations without inventing movement

I like watching ants. There's something beautiful about their little
roads: the usual routes, occasional detours, and busy intersections.

We're ants too, in that sense. I'm one of them, just equipped with an Android
phone and a slightly unhealthy interest in SQLite.

Watch those routes for a month and the questions get interesting. Do we keep
taking the same circuits? When two trails cross, were we actually there at
the same time?

So I wrote [Cartochron](https://github.com/cartochron/cartochron): a small
Python receiver, SQLite database, and Leaflet map for collecting location
observations and poking around their history.

Not another GPS dashboard. I wanted to look back through recordings, compare
different runs, find recurring places, and examine where two sets of
observations come close in space and time.

Preferably without the map inventing adventures between two GPS fixes.

## First, some imaginary ants

Before involving real phones, try the included demonstration:

```sh
git clone https://github.com/cartochron/cartochron.git
cd cartochron
make demo
```

Open <http://127.0.0.1:8877/>.

The demo has several synthetic recordings: different routes, stale positions,
missing intervals, and a couple of suspiciously convenient crossings.

Try `demo-oneplus-morning` in **History**. There's a gap in the recording.
Inspect its endpoints; the map doesn't know what happened in between.

Then compare `demo-oneplus-evening` with `demo-lg-evening`. Look at the
reported coordinates and their receipt times. For a different kind of
coincidence, compare routes that cross geographically but were recorded at
different times.

There's more under **Compare routes**, **What was here?**, and the history
overlap searches. The in-app **Guide** explains the controls.

All synthetic. Nobody's actual movements, no private locations, and no
unfortunate neighbour accidentally becoming a research specimen.

## The receiver

For longer recordings, I use Docker Compose with a persistent SQLite database.

From the Cartochron checkout:

```sh
install -d -m 700 data

( umask 077; printf 'operator:%s\n' \
    "$(openssl rand -hex 32)" > data/auth )

( umask 077; printf 'CARTOCHRON_UID=%s\nCARTOCHRON_GID=%s\n' \
    "$(id -u)" "$(id -g)" > .env )

docker compose up --build -d
```

Open <http://127.0.0.1:8765/> and use the credentials from `data/auth`.

That's the receiver. It stores observations in `data/observations.sqlite3`,
serves the map, and survives container restarts without losing the recording
history.

It listens on host loopback. If you want it on a VPS, put HTTPS in front of
it rather than exposing the backend and its Basic-auth credentials over the
Internet.

## Feed the beast

Cartochron doesn't care where an observation came from, provided an adapter
speaks its HTTP API.

For ordinary GPS recording, there's
[cartochron-gpsd](https://github.com/cartochron/cartochron-gpsd). It reads
GPSD reports and forwards valid position fixes to the receiver.

The Android side is familiar from my
[Kismet wardriving setup](wardriving-kismet-gpsd.html): install
[GPSd Forwarder](https://f-droid.org/en/packages/io.github.tiagoshibata.gpsdclient/)
or [gpsdRelay](https://f-droid.org/en/packages/io.github.project_kaat.gpsdrelay/)
from F-Droid on a spare phone. gpsdRelay has a configurable *NMEA generation
interval* (in milliseconds), worth trying for longer recordings. It controls
requested GPS location updates, but raw NMEA sentences can still be relayed
as they arrive; check the actual sampling and battery use on your phone.

One phone works. Two are more interesting.

```text
Android phone A --- UDP/29998 ---+
                                 |
Android phone B --- UDP/29999 ---+-- GPSD
                                      |
                                cartochron-gpsd
                                      |
                                      v
                               Cartochron
                                SQLite + map
```

Clone the adapter alongside the receiver:

```sh
cd ..
git clone https://github.com/cartochron/cartochron-gpsd.git
cd cartochron-gpsd

cp sources.toml.example sources.toml
cp .env.example .env
```

The sample `sources.toml` already contains two input channels. Change their
names if you like, and assign each phone its own UDP port.

In `.env`, set `GPSD_BIND_IP` to the laptop's address reachable by the phones,
and set `COLLECTOR_UID` and `COLLECTOR_GID` to your `id -u` and `id -g` values.
The collector uses the receiver's private authentication file from the sibling
checkout.

Then:

```sh
make check-config
docker compose up --build -d
docker compose exec gpsd gpspipe -w -n 30
```

Configure each phone's forwarder with the corresponding host address and UDP
port. Check that GPSD is actually receiving valid fixes, then watch
Cartochron's **Monitor**.

A small gotcha: my Kismet wardriving stack uses GPSD ports `2947` and
`29998` too. Stop that stack before starting this one with the defaults.

Two daemons, one socket. Nobody wins.

The full [GPSD Compose guide](https://github.com/cartochron/cartochron-gpsd/blob/master/docs/compose.md)
covers enrollment, additional phones, and troubleshooting. Keep the UDP
inputs on a trusted network: a configured input channel isn't authentication
of the phone behind it.

## Give it some history

Take the same little circuit a few times, preferably with different stops and
at different hours. Use your own devices, or devices whose owners have
explicitly agreed to the recording.

A few days of observations become much more interesting than watching a
marker move in real time.

In **Monitor**, you can follow the latest run for a channel. In **History**,
older runs remain separate. Restarting a collector starts a new recording
rather than stitching yesterday's last coordinate to today's first one.

You can compare routes, inspect individual observations, search a place, or
look for nearby reports from two different recording runs.

Here's where timestamps become useful. Two paths crossing on a map might be
interesting. Two reported positions close together within a few minutes are
more interesting. Neither alone tells us that two people met, but now there's
something concrete to examine.

Cartochron also keeps the server's receipt time separate from a GPSD-reported
measurement time. An old position arriving today shouldn't quietly become a
fresh GPS measurement.

The distinction matters when a feed disconnects, a phone wakes up, or an
adapter reconnects. Missing observations stay missing. The map doesn't get
to fill in the blanks just because a straight line looks nicer.

## Other ways to collect

There's also [cartochron-metasploit](https://github.com/cartochron/cartochron-metasploit),
an adapter for authorized Android Meterpreter sessions.

It uses the session's reported network-provider location rather than GPSD.
Those positions may be cached, and their original measurement time is unknown.
Useful for certain laboratory experiments, but not something to confuse with
a fresh GPS fix.

The receiver and both adapters are independent repositories. The
[Cartochron handbook](https://github.com/cartochron/cartochron/blob/master/docs/handbook.md)
has the detailed investigation workflows; the
[operations guide](https://github.com/cartochron/cartochron/blob/master/docs/operations.md)
covers backups, authentication, and deployment.

Keep the recordings and database private. A month's location history is
rather more personal than the cute little dots suggest.
