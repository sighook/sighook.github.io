#!/bin/sh
# Generate sitemap.xml from HTML files

SITE_DOMAIN=${1:-sighook.github.io}

echo '<?xml version="1.0" encoding="UTF-8"?>' > sitemap.xml
echo '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">' >> sitemap.xml

for f in *.html; do
	fname=$(basename "$f")
	echo "  <url>" >> sitemap.xml
	echo "    <loc>https://$SITE_DOMAIN/$fname</loc>" >> sitemap.xml
	echo "    <lastmod>$(date -r "$f" +%F)</lastmod>" >> sitemap.xml
	if [ "$fname" = "index.html" ]; then
		echo "    <priority>1.0</priority>" >> sitemap.xml
	else
		echo "    <priority>0.7</priority>" >> sitemap.xml
	fi
	echo "  </url>" >> sitemap.xml
done

echo '</urlset>' >> sitemap.xml

if command -v xmllint >/dev/null 2>&1; then
	xmllint --noout sitemap.xml
fi

echo "sitemap.xml generated for $SITE_DOMAIN"

# End of file.
