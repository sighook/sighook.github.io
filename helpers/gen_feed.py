#!/usr/bin/env python3
"""Build a small RSS feed from the same Pandoc metadata used by note pages."""

import json
import subprocess
import sys
from datetime import date, datetime, time, timezone
from email.utils import format_datetime
from pathlib import Path
from xml.etree import ElementTree as ET


def note_metadata(source):
    """Read title, date and description via Pandoc, not a second YAML parser."""
    document = json.loads(subprocess.check_output(
        ["pandoc", "--to=json", str(source)], text=True
    ))

    def field(name):
        value = document["meta"][name]
        if value["t"] == "MetaString":
            return value["c"]
        if value["t"] == "MetaInlines":
            return "".join(
                part["c"] if part["t"] == "Str" else " "
                for part in value["c"]
                if part["t"] in ("Str", "Space", "SoftBreak")
            ).strip()
        raise ValueError(f"{source}: {name} must be plain text")

    title, published, summary = (field(name) for name in
                                 ("title", "date", "description"))
    if not title or not summary:
        raise ValueError(f"{source}: title and description are required")
    return date.fromisoformat(published), title, summary


def main(domain, output, sources):
    rss = ET.Element("rss", version="2.0")
    channel = ET.SubElement(rss, "channel")
    for name, value in (
        ("title", "sighook.im — Notes"),
        ("link", f"https://{domain}/notes.html"),
        ("description", "Security research, systems engineering, and field notes."),
        ("language", "en"),
    ):
        ET.SubElement(channel, name).text = value

    notes = [(note_metadata(source), source) for source in sources]
    for (published, title, summary), source in sorted(
        notes, key=lambda note: (note[0][0], note[1].stem), reverse=True
    ):
        url = f"https://{domain}/notes/{source.stem}.html"
        item = ET.SubElement(channel, "item")
        for name, value in (
            ("title", title), ("link", url), ("description", summary),
            ("guid", url),
            ("pubDate", format_datetime(datetime.combine(
                published, time.min, tzinfo=timezone.utc
            ))),
        ):
            ET.SubElement(item, name).text = value

    ET.indent(rss)
    ET.ElementTree(rss).write(output, encoding="utf-8", xml_declaration=True)


if __name__ == "__main__":
    if len(sys.argv) < 3:
        sys.exit("usage: gen_feed.py DOMAIN OUTPUT [NOTE.md ...]")
    main(sys.argv[1], sys.argv[2], [Path(name) for name in sys.argv[3:]])
