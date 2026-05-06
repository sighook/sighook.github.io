#!/bin/sh
# Generate robots.txt

SITE_DOMAIN=${1:-sighook.github.io}

cat > robots.txt <<EOF
User-agent: *
Allow: /

Sitemap: https://$SITE_DOMAIN/sitemap.xml
EOF

echo "robots.txt generated for $SITE_DOMAIN"

# End of file.
