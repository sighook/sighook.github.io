# project metadata
SITE_DOMAIN = sighook.im

# paths
BUILDDIR = build
WWWDIR = /var/www/$(SITE_DOMAIN)

# tools
PANDOC = pandoc

# HTML generation
PANDOC_HTML_FLAGS = --standalone --template=templates/template.html.in
