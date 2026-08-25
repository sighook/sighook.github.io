include config.mk

HTML = $(BUILDDIR)/about.html \
       $(BUILDDIR)/cv.html \
       $(BUILDDIR)/index.html \
       $(BUILDDIR)/key.html \
       $(BUILDDIR)/projects.html \
       $(BUILDDIR)/research.html

ASSETS = $(BUILDDIR)/assets/favicon.png \
         $(BUILDDIR)/assets/style.css

META = $(BUILDDIR)/CNAME \
       $(BUILDDIR)/robots.txt \
       $(BUILDDIR)/sitemap.xml

PDF = $(BUILDDIR)/cv.pdf

all: $(HTML) $(ASSETS) $(META) $(PDF)

$(BUILDDIR)/%.html: src/%.md templates/template.html.in
	mkdir -p $(BUILDDIR)
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

$(BUILDDIR)/robots.txt: helpers/gen_robots.sh config.mk
	mkdir -p $(BUILDDIR)
	./helpers/gen_robots.sh '$(SITE_DOMAIN)' $@

$(BUILDDIR)/sitemap.xml: helpers/gen_sitemap.sh $(HTML) config.mk
	mkdir -p $(BUILDDIR)
	./helpers/gen_sitemap.sh '$(SITE_DOMAIN)' $(BUILDDIR) $@

$(BUILDDIR)/cv.pdf: src/cv.md config.mk
	mkdir -p $(BUILDDIR)
	$(PANDOC) $(PANDOC_PDF_FLAGS) $< -o $@

install: all
	mkdir -p $(DESTDIR)$(WWWDIR)/assets
	cp -f $(HTML) $(META) $(PDF) $(DESTDIR)$(WWWDIR)/
	cp -f $(ASSETS) $(DESTDIR)$(WWWDIR)/assets/

uninstall:
	cd $(DESTDIR)$(WWWDIR) && \
		rm -f about.html cv.html index.html key.html projects.html research.html \
		       CNAME robots.txt sitemap.xml cv.pdf
	rm -f $(DESTDIR)$(WWWDIR)/assets/favicon.png \
	      $(DESTDIR)$(WWWDIR)/assets/style.css
	rmdir $(DESTDIR)$(WWWDIR)/assets 2>/dev/null || :
	rmdir $(DESTDIR)$(WWWDIR) 2>/dev/null || :

clean:
	rm -rf $(BUILDDIR)

.PHONY: all install uninstall clean
