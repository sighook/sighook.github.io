# sighook.im

Source for [sighook.im](https://sighook.im/).

The source branch contains Markdown, templates, styles, and build helpers only.
Generated HTML, metadata, and the CV PDF are deployment artifacts; they are not
committed to the source branch.

## Write a note

Add a Markdown file under `src/notes/` with Pandoc metadata:

```yaml
---
title: A descriptive title
date: 2026-11-07
description: A short, plain-text summary for the feed and search results.
note: true
root: ../
page-class: note
---
```

The filename becomes its stable URL, for example
`src/notes/example.md` → `/notes/example.html`. Write normal Markdown below
that header. Add a link to the new entry in `src/notes.md` (newest first).
The Makefile discovers note pages, includes them in `sitemap.xml`, and
regenerates `feed.xml` from the Pandoc title/date/description metadata.
No separate feed entries or build manifest edits are needed. Avoid renaming
published note files: their URLs are permanent references.

## Publish

Publication runs entirely in GitHub Actions. Edit the source, commit it, and push
`master`. The `Deploy GitHub Pages` workflow then:

- starts an Ubuntu runner;
- installs Pandoc, XeLaTeX, and the validation tools;
- builds and checks the exact public-file manifest, including notes and RSS;
- uploads the verified artifact to GitHub Pages; and
- deploys it to the protected `github-pages` environment.

No Pandoc or TeX installation is required on the editing machine.

Before the first deployment, select **Settings → Pages → Build and deployment →
Source → GitHub Actions** in the repository. Subsequent pushes to `master` deploy
automatically. A deployment can also be started manually from the Actions tab.

## Local preview with Docker Compose

Only Docker Engine and the Compose plugin are required on the host. The
container has the same Pandoc/TeX toolchain as the deployment workflow; it
builds and validates the complete site before serving anything.

```sh
docker compose up --build
```

Open <http://127.0.0.1:8000/>. After editing Markdown or CSS, rebuild the
preview with `docker compose restart site`. Stop it with Ctrl-C, or run
`docker compose down` if started in the background.

The checkout is mounted **read-only** and generated files stay inside the
container. The preview listens on host loopback only, not the public network.
The canonical URLs in RSS and the sitemap still point to `sighook.im`.

## Optional local check (without Docker)

Local generation is useful for previewing or debugging, but it is not part of the
publication path. It requires `make`, Python 3, `pandoc`, XeLaTeX, `xmllint`, `pdfinfo`, and
`pdftotext`.

Build and validate the complete publishable tree:

```sh
make clean check
```

Remove generated output:

```sh
make clean
```

## Optional staged install

The default web root is `/var/www/sighook.im`. Staged installs follow the usual
`DESTDIR` contract:

```sh
make install DESTDIR="$pkgdir"
```

`WWWDIR` may be overridden when a different final web root is required.

## Retire the old branch

After the first Actions deployment succeeds and the live site is verified, the
old `gh-pages` branch is no longer a publication source and may be deleted.
