# project metadata
SITE_DOMAIN = sighook.im

# paths
BUILDDIR = build
WORKDIR = .build
WWWDIR = /var/www/$(SITE_DOMAIN)

# tools
PANDOC = pandoc
SHA256 = sha256sum

# HTML generation
PANDOC_HTML_FLAGS = --standalone --template=templates/template.html.in

# PDF generation
PDF_ENGINE = xelatex
PANDOC_PDF_FLAGS = --pdf-engine=$(PDF_ENGINE) --metadata title= \
                   -V title-meta='Alexandr Savca - Security Engineer' \
                   -V author-meta='Alexandr Savca' \
                   -V subject='Curriculum Vitae' \
                   -V documentclass=extarticle \
                   -V geometry:margin=0.58in -V fontsize=9pt \
                   -V colorlinks=true -V urlcolor=blue
