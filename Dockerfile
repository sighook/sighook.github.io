FROM ubuntu:24.04

# Match the toolchain used by GitHub Actions. Nothing is installed on the host.
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    libxml2-utils \
    lmodern \
    make \
    pandoc \
    poppler-utils \
    python3 \
    texlive-fonts-recommended \
    texlive-latex-recommended \
    texlive-xetex \
    && rm -rf /var/lib/apt/lists/*

# The bind-mounted checkout may be owned by a different host UID.
RUN git config --system --add safe.directory /site

WORKDIR /site

# The checkout is mounted read-only; build files stay inside the container.
CMD ["sh", "-ec", "make BUILDDIR=/tmp/site-build WORKDIR=/tmp/site-work check && exec python3 -m http.server 8000 --bind 0.0.0.0 --directory /tmp/site-build"]
