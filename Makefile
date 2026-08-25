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

all: $(HTML) $(ASSETS) $(META)

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

clean:
	rm -rf $(BUILDDIR)

.PHONY: all clean
