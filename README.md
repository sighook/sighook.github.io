# sighook.im

Source for [sighook.im](https://sighook.im/).

The source branch contains Markdown, templates, styles, and build helpers only.
Generated HTML, metadata, and the CV PDF are deployment artifacts; they are not
committed to the source branch.

## Publish

Publication runs entirely in GitHub Actions. Edit the source, commit it, and push
`master`. The `Deploy GitHub Pages` workflow then:

- starts an Ubuntu runner;
- installs Pandoc, XeLaTeX, and the validation tools;
- builds and checks the exact public-file manifest;
- uploads the verified artifact to GitHub Pages; and
- deploys it to the protected `github-pages` environment.

No Pandoc or TeX installation is required on the editing machine.

Before the first deployment, select **Settings → Pages → Build and deployment →
Source → GitHub Actions** in the repository. Subsequent pushes to `master` deploy
automatically. A deployment can also be started manually from the Actions tab.

## Optional local check

Local generation is useful for previewing or debugging, but it is not part of the
publication path. It requires `make`, `pandoc`, XeLaTeX, `xmllint`, `pdfinfo`, and
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
