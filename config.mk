# project metadata
SITE_DOMAIN = sighook.im

# paths
BUILDDIR = build
WWWDIR = /var/www/$(SITE_DOMAIN)

# tools
PANDOC = pandoc

# HTML generation
PANDOC_HTML_FLAGS = --standalone --template=templates/template.html.in

# PDF generation
PDF_ENGINE = xelatex
PANDOC_PDF_FLAGS = --pdf-engine=$(PDF_ENGINE) --metadata title= \
                   -V geometry:margin=0.65in -V fontsize=10pt \
                   -V colorlinks=true -V urlcolor=blue

# publication
PUBLISH_REMOTE = origin
PUBLISH_BRANCH = gh-pages
