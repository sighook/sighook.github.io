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
PDF_HEADER = $(BUILDDIR)/cv-pdf-header.tex

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

$(PDF_HEADER): src/cv.md config.mk
	mkdir -p $(BUILDDIR)
	id=`$(SHA256) $< | cut -c1-32`; \
		printf '\\special{pdf:trailerid [<%s> <%s>]}\n' "$$id" "$$id" > $@

$(BUILDDIR)/cv.pdf: src/cv.md $(PDF_HEADER) config.mk
	mkdir -p $(BUILDDIR)
	epoch=`git log -1 --format=%ct -- $< 2>/dev/null || printf '0\n'`; \
		SOURCE_DATE_EPOCH=$${SOURCE_DATE_EPOCH:-$$epoch} \
		$(PANDOC) $(PANDOC_PDF_FLAGS) --include-in-header=$(PDF_HEADER) $< -o $@

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

publish: all
	./helpers/publish.sh '$(PUBLISH_REMOTE)' '$(PUBLISH_BRANCH)' '$(MAKE)'

clean:
	rm -rf $(BUILDDIR)

.PHONY: all install uninstall publish clean
