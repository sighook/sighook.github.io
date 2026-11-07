include config.mk

PAGES = about cv index key notes projects research
HTML = $(addprefix $(BUILDDIR)/,$(addsuffix .html,$(PAGES)))
NOTE_SOURCES = $(sort $(wildcard src/notes/*.md))
NOTE_HTML = $(patsubst src/%.md,$(BUILDDIR)/%.html,$(NOTE_SOURCES))
ALL_HTML = $(HTML) $(NOTE_HTML)

ASSETS = $(BUILDDIR)/assets/favicon.png \
         $(BUILDDIR)/assets/style.css

META = $(BUILDDIR)/CNAME \
       $(BUILDDIR)/.nojekyll \
       $(BUILDDIR)/robots.txt \
       $(BUILDDIR)/sitemap.xml \
       $(BUILDDIR)/feed.xml

PDF = $(BUILDDIR)/cv.pdf
PDF_HEADER = $(WORKDIR)/cv-pdf-header.tex

all: $(ALL_HTML) $(ASSETS) $(META) $(PDF)

$(BUILDDIR)/%.html: src/%.md templates/template.html.in
	mkdir -p $(dir $@)
	$(PANDOC) $(PANDOC_HTML_FLAGS) $< -o $@

$(BUILDDIR)/assets/favicon.png: assets/favicon.png
	mkdir -p $(BUILDDIR)/assets
	cp -f $< $@

$(BUILDDIR)/assets/style.css: assets/style.css
	mkdir -p $(BUILDDIR)/assets
	cp -f $< $@

$(BUILDDIR)/CNAME: config.mk
	mkdir -p $(BUILDDIR)
	printf '%s\n' '$(SITE_DOMAIN)' > $@

$(BUILDDIR)/.nojekyll:
	mkdir -p $(BUILDDIR)
	: > $@

$(BUILDDIR)/robots.txt: helpers/gen_robots.sh config.mk
	mkdir -p $(BUILDDIR)
	./helpers/gen_robots.sh '$(SITE_DOMAIN)' $@

$(BUILDDIR)/sitemap.xml: helpers/gen_sitemap.sh $(ALL_HTML) config.mk
	mkdir -p $(BUILDDIR)
	./helpers/gen_sitemap.sh '$(SITE_DOMAIN)' $(BUILDDIR) $@

$(BUILDDIR)/feed.xml: helpers/gen_feed.py $(NOTE_SOURCES) config.mk
	mkdir -p $(BUILDDIR)
	python3 helpers/gen_feed.py $(SITE_DOMAIN) $@ $(NOTE_SOURCES)

$(PDF_HEADER): src/cv.md config.mk
	mkdir -p $(WORKDIR)
	id=`$(SHA256) $< | cut -c1-32`; \
		printf '\\special{pdf:trailerid [<%s> <%s>]}\n' "$$id" "$$id" > $@

$(BUILDDIR)/cv.pdf: src/cv.md $(PDF_HEADER) config.mk
	mkdir -p $(BUILDDIR)
	epoch=`git log -1 --format=%ct -- $< 2>/dev/null || printf '0\n'`; \
		SOURCE_DATE_EPOCH=$${SOURCE_DATE_EPOCH:-$$epoch} \
		$(PANDOC) $(PANDOC_PDF_FLAGS) --include-in-header=$(PDF_HEADER) $< -o $@

check: all
	./helpers/check_build.sh $(BUILDDIR)

install: all
	mkdir -p $(DESTDIR)$(WWWDIR)/assets $(DESTDIR)$(WWWDIR)/notes
	cp -f $(HTML) $(META) $(PDF) $(DESTDIR)$(WWWDIR)/
	cp -f $(NOTE_HTML) $(DESTDIR)$(WWWDIR)/notes/
	cp -f $(ASSETS) $(DESTDIR)$(WWWDIR)/assets/

uninstall:
	cd $(DESTDIR)$(WWWDIR) && \
		rm -f about.html cv.html index.html key.html notes.html projects.html research.html \
		       .nojekyll CNAME robots.txt sitemap.xml feed.xml cv.pdf
	rm -f $(DESTDIR)$(WWWDIR)/assets/favicon.png \
	      $(DESTDIR)$(WWWDIR)/assets/style.css
	rm -f $(DESTDIR)$(WWWDIR)/notes/*.html
	rmdir $(DESTDIR)$(WWWDIR)/notes 2>/dev/null || :
	rmdir $(DESTDIR)$(WWWDIR)/assets 2>/dev/null || :
	rmdir $(DESTDIR)$(WWWDIR) 2>/dev/null || :

clean:
	rm -rf $(BUILDDIR) $(WORKDIR)

.PHONY: all check install uninstall clean
