#!/bin/sh
# Generate sitemap.xml from generated HTML files.

set -eu

SITE_DOMAIN=${1:-sighook.github.io}
HTML_DIR=${2:-.}
OUTPUT=${3:-sitemap.xml}

{
	echo '<?xml version="1.0" encoding="UTF-8"?>'
	echo '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'

	for f in "$HTML_DIR"/*.html; do
		fname=$(basename "$f")
		echo '  <url>'
		echo "    <loc>https://$SITE_DOMAIN/$fname</loc>"
		echo "    <lastmod>$(date -r "$f" +%F)</lastmod>"
		if [ "$fname" = "index.html" ]; then
			echo '    <priority>1.0</priority>'
		else
			echo '    <priority>0.7</priority>'
		fi
		echo '  </url>'
	done

	echo '</urlset>'
} > "$OUTPUT"

if command -v xmllint >/dev/null 2>&1; then
	xmllint --noout "$OUTPUT"
fi

# End of file.
