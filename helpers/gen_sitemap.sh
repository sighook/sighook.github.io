#!/bin/sh
# Generate sitemap.xml from generated HTML files.

set -eu

SITE_DOMAIN=${1:-sighook.github.io}
HTML_DIR=${2:-.}
OUTPUT=${3:-sitemap.xml}

{
	echo '<?xml version="1.0" encoding="UTF-8"?>'
	echo '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'

	find "$HTML_DIR" -type f -name '*.html' | LC_ALL=C sort | while IFS= read -r f; do
		fname=${f#"$HTML_DIR"/}
		echo '  <url>'
		echo "    <loc>https://$SITE_DOMAIN/$fname</loc>"
		# A rebuilt HTML file is not necessarily a changed page.
		lastmod=$(git log -1 --format=%cs -- "src/${fname%.html}.md" 2>/dev/null || :)
		[ -n "$lastmod" ] || lastmod=$(date -r "$f" +%F)
		echo "    <lastmod>$lastmod</lastmod>"
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
