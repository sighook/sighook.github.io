---
title: Wardriving with Kismet and GPSD
description: A practical Docker Compose wardriving setup with Kismet, GPSD, an Android phone, and optional Kismon.
date: 2026-11-07
note: true
root: ../
page-class: note
---

# Wardriving with Kismet and GPSD

I wanted a portable wardriving setup without installing half the universe on
my laptop.

[Kismet](https://www.kismetwireless.net/) captures Wi-Fi traffic, GPSD receives
coordinates from an Android phone, and [Kismon](https://github.com/Kismon/kismon)
provides an optional map and signal graphs. Docker Compose keeps the
dependencies and configuration together.

The setup is available at
[kismet-gpsd-setup](https://github.com/sighook/kismet-gpsd-setup), with
installation instructions and troubleshooting notes.

## The plumbing

```text
Android phone
    | NMEA / UDP 29998
    v
   GPSD ---- TCP 2947 ----> Kismet ---> recordings
                              |
                              +----> Kismon
```

Kismet uses the host's wireless adapter in monitor mode. GPSD receives NMEA
sentences from the phone, preferably over USB tethering. The Kismet web
interface is available on port 2501, and Kismon connects to it separately.

The Docker image installs Kismet `2026-10-R1` from the official package
repository. Capture logs survive container restarts.

## Give the old phone a job

I'd recommend using a spare Android phone rather than your daily one.

Install [GPSd Forwarder](https://f-droid.org/en/packages/io.github.tiagoshibata.gpsdclient/)
or [gpsdRelay](https://f-droid.org/en/packages/io.github.project_kaat.gpsdrelay/)
from F-Droid. Enable location services and send NMEA over UDP to the laptop's
tethering IP address on port `29998`.

gpsdRelay also lets you set an *NMEA generation interval* in milliseconds.
For longer sessions, try a less frequent update and check the resulting GPSD
feed. The setting controls requested GPS location updates, not every raw NMEA
sentence, so don't assume it will automatically save battery.

Calls, app switching, background restrictions, and aggressive battery
management are unnecessary complications during a recording session. A
dedicated phone can stay connected, powered, and doing exactly one job.

Even an old Android handset is perfectly useful here, provided it can acquire
a GPS fix and forward it reliably.

Not a bad retirement.

## Before heading outside

Start the containers:

```sh
docker compose --profile gui up --build -d
```

Check the GPS feed:

```sh
docker compose exec gpsd gpsmon localhost:2947
```

Then open Kismet at <http://127.0.0.1:2501/> and verify that the wireless
adapter is capturing and the GPS source has a valid fix.

A few things worth remembering:

- USB tethering provides a direct network connection without involving the
  capture adapter.
- Android battery optimization can interfere with background forwarding.
  Check the app's battery settings.
- If GPS updates stop, check Kismet's logs. In my test, it detected and
  reported the missing GPSD updates.
- Kismon is optional. The recording should not depend on the GUI.
- Keep capture logs and location history private. They're stored under
  `data/kismet_logs/`.

That's the whole arrangement: a Wi-Fi adapter, an old Android phone, GPSD,
and Kismet in containers. Kismon is there when I want a map.

The [repository](https://github.com/sighook/kismet-gpsd-setup) contains
the configuration, setup instructions, and troubleshooting notes.
Nothing particularly clever, just a working arrangement that's easy to
reproduce.
