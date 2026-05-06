CNAME = sighook.im
MD = $(wildcard src/*.md)
HTML = $(patsubst src/%.md, %.html, $(MD))

all: $(HTML) robots.txt sitemap.xml CNAME

%.html: src/%.md templates/template.html.in
	pandoc $< -o $@ --standalone \
		--template=templates/template.html.in

robots.txt: ./helpers/gen_robots.sh $(HTML)
	./helpers/gen_robots.sh $(CNAME)

sitemap.xml: ./helpers/gen_sitemap.sh $(HTML)
	./helpers/gen_sitemap.sh $(CNAME)

CNAME:
	echo $(CNAME) > CNAME

clean:
	rm -f *.html robots.txt sitemap.xml CNAME

.PHONY: all clean
