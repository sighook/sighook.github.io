all: index.html cv.html key.html projects.html

%.html: %.pod
	pod2html --css=style.css --title="$@" --noindex $^ > $@

clean:
	rm *.html

.PHONY: all clean
