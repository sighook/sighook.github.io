# sighook.im

Source for [sighook.im](https://sighook.im/).

The source branch contains Markdown, templates, styles, and build helpers only.
Generated HTML, metadata, and the CV PDF are written to `build/`.

## Build

Requirements:

- `make`
- `pandoc`
- XeLaTeX (`xelatex`) for `cv.pdf`

Build the complete publishable tree:

```sh
make
```

Remove generated output:

```sh
make clean
```

## Install

The default web root is `/var/www/sighook.im`. Staged installs follow the usual
`DESTDIR` contract:

```sh
make install DESTDIR="$pkgdir"
```

`WWWDIR` may be overridden when a different final web root is required.

## Publish

`make publish` builds the current source, installs the explicit public-file
manifest into a temporary Git worktree for the `gh-pages` branch, commits the
resulting exact snapshot, and pushes the branch to `origin`.

```sh
make publish
```

The source worktree must be clean. `PUBLISH_REMOTE` and `PUBLISH_BRANCH` may be
overridden from `make` when necessary.

GitHub Pages should be configured to serve the root of the `gh-pages` branch.
