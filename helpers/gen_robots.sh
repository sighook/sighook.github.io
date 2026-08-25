#!/bin/sh
# Generate robots.txt.

set -eu

SITE_DOMAIN=${1:-sighook.github.io}
OUTPUT=${2:-robots.txt}

cat > "$OUTPUT" <<EOF_INNER
User-agent: *
Allow: /

Sitemap: https://$SITE_DOMAIN/sitemap.xml
EOF_INNER

# End of file.
