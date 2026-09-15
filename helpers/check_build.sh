#!/bin/sh
# Validate that a build is complete and contains only public files.

set -eu

OUTPUT=${1:-build}

if [ ! -d "$OUTPUT" ]; then
	echo "check-build: missing output directory: $OUTPUT" >&2
	exit 1
fi

CHECK_TMP=$(mktemp -d "${TMPDIR:-/tmp}/sighook-check.XXXXXX")
cleanup()
{
	rm -rf "$CHECK_TMP"
}
trap cleanup EXIT HUP INT TERM

cat > "$CHECK_TMP/expected" <<'EOF_EXPECTED'
.nojekyll
CNAME
about.html
assets/favicon.png
assets/style.css
cv.html
cv.pdf
index.html
key.html
projects.html
research.html
robots.txt
sitemap.xml
EOF_EXPECTED

find "$OUTPUT" -type f | sed "s#^$OUTPUT/##" | LC_ALL=C sort > "$CHECK_TMP/actual"

if ! cmp -s "$CHECK_TMP/expected" "$CHECK_TMP/actual"; then
	echo 'check-build: public-file manifest does not match:' >&2
	diff -u "$CHECK_TMP/expected" "$CHECK_TMP/actual" >&2 || :
	exit 1
fi

if find "$OUTPUT" -type l -print -quit | grep -q .; then
	echo 'check-build: symbolic links are not allowed in the Pages artifact' >&2
	exit 1
fi

for file in CNAME robots.txt sitemap.xml assets/favicon.png assets/style.css cv.pdf; do
	if [ ! -s "$OUTPUT/$file" ]; then
		echo "check-build: empty public file: $file" >&2
		exit 1
	fi
done

for page in about cv index key projects research; do
	html="$OUTPUT/$page.html"
	if ! grep -Fq '<!doctype html>' "$html" || ! grep -Fq '<html lang="en">' "$html"; then
		echo "check-build: malformed HTML shell: $page.html" >&2
		exit 1
	fi

	if ! grep -Fq "https://sighook.im/$page.html" "$OUTPUT/sitemap.xml"; then
		echo "check-build: sitemap entry missing: $page.html" >&2
		exit 1
	fi
done

if [ "$(cat "$OUTPUT/CNAME")" != 'sighook.im' ]; then
	echo 'check-build: CNAME does not contain the canonical domain' >&2
	exit 1
fi

if ! grep -Fq 'Sitemap: https://sighook.im/sitemap.xml' "$OUTPUT/robots.txt"; then
	echo 'check-build: robots.txt does not advertise the canonical sitemap' >&2
	exit 1
fi

xmllint --noout "$OUTPUT/sitemap.xml"

PDF_PAGES=$(pdfinfo "$OUTPUT/cv.pdf" | awk '/^Pages:/ { print $2 }')
case "$PDF_PAGES" in
	''|*[!0-9]*|0)
		echo 'check-build: cv.pdf has no readable pages' >&2
		exit 1
		;;
esac

if ! pdftotext "$OUTPUT/cv.pdf" - | grep -Fq 'Alexandr Savca'; then
	echo 'check-build: cv.pdf does not contain the expected CV text' >&2
	exit 1
fi

echo "check-build: verified $(wc -l < "$CHECK_TMP/actual" | tr -d ' ') public files"

# End of file.
