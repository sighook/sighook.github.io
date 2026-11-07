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
feed.xml
index.html
key.html
notes.html
projects.html
research.html
robots.txt
sitemap.xml
EOF_EXPECTED

for source in src/notes/*.md; do
	[ -f "$source" ] || continue
	printf 'notes/%s.html\n' "$(basename "$source" .md)"
done >> "$CHECK_TMP/expected"
LC_ALL=C sort -o "$CHECK_TMP/expected" "$CHECK_TMP/expected"

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

for file in CNAME robots.txt sitemap.xml feed.xml assets/favicon.png assets/style.css cv.pdf; do
	if [ ! -s "$OUTPUT/$file" ]; then
		echo "check-build: empty public file: $file" >&2
		exit 1
	fi
done

for page in about cv index key notes projects research; do
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

for source in src/notes/*.md; do
	[ -f "$source" ] || continue
	page="notes/$(basename "$source" .md).html"
	if ! grep -Fq '<!doctype html>' "$OUTPUT/$page" ||
	   ! grep -Fq '<body class="note">' "$OUTPUT/$page"; then
		echo "check-build: malformed note: $page" >&2
		exit 1
	fi
	if ! grep -Fq "$page" "$OUTPUT/notes.html"; then
		echo "check-build: note is missing from notes index: $page" >&2
		exit 1
	fi
	if ! grep -Fq "https://sighook.im/$page" "$OUTPUT/sitemap.xml"; then
		echo "check-build: sitemap entry missing: $page" >&2
		exit 1
	fi
	if ! grep -Fq "https://sighook.im/$page" "$OUTPUT/feed.xml"; then
		echo "check-build: feed entry missing: $page" >&2
		exit 1
	fi
done

xmllint --noout "$OUTPUT/sitemap.xml" "$OUTPUT/feed.xml"

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
