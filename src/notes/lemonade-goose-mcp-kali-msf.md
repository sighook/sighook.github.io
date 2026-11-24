---
title: Local AI-Assisted Security Lab with Kali, Metasploit, Goose, and Lemonade
description: How to deploy a hardened, read-only Kali and Metasploit container and connect both MCP servers to Goose over STDIO backed by a local Lemonade LLM.
date: 2026-11-24
note: true
root: ../
page-class: note
tags: [kali-linux, metasploit, mcp, goose, local-llm, docker, appsec]
---

Following up on our [local OWASP ZAP setup](/notes/lemonade-goose-mcp-zap.html),
the next step is giving **Goose** controlled access to standard network
utilities and **Metasploit** inside an isolated container — while keeping
inference 100% local via **Lemonade Server**.

Rather than exposing network ports to the host, we can run `mcp-kali-server`
and `metasploitmcp` inside a locked-down, read-only container bound strictly to
loopback (`127.0.0.1`), and bridge Goose directly into the container via
`docker exec` over **STDIO**.

## Architecture Overview

1. **Lemonade Server** handles local model inference on `http://localhost:13305/v1`.

2. **Hardened Kali Container (`kali-mcp-lab`)** runs as a non-root user
   (`uid 10001`) with a read-only root filesystem, `cap_drop: ALL`, and minimal
   Linux capabilities (`NET_RAW`, `NET_ADMIN`, `NET_BIND_SERVICE`) applied via
   `setcap` only where needed.

3. **Goose** attaches two `STDIO` extensions (`Kali Lab` and `MSF Lab`) using
   `docker exec -i` — eliminating the need to expose RPC or MCP ports on the host
   network.

---

## Step 1: Build the Hardened Kali & Metasploit Container

Create a new directory for your lab stack and add the following three files.

### 1. `Dockerfile`

This image installs `mcp-kali-server`, `metasploitmcp`, and core network
utilities, grants raw socket capabilities to `nmap` and `tcpdump`, and drops
privileges to an unprivileged `lab` user:

```dockerfile
FROM kalilinux/kali-rolling:latest

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        kali-linux-headless \
        mcp-kali-server \
        metasploitmcp \
        metasploit-framework \
        iproute2 \
        iputils-ping \
        dnsutils \
        net-tools \
        traceroute \
        whois \
        tcpdump \
        netcat-openbsd \
        socat \
        jq \
        nmap \
        libcap2-bin \
        curl \
        gobuster \
        dirb \
        nikto \
        ca-certificates \
    && setcap cap_net_raw,cap_net_admin,cap_net_bind_service+eip /usr/bin/nmap \
    && setcap cap_net_raw,cap_net_admin+eip /usr/bin/tcpdump \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --create-home --uid 10001 --shell /usr/sbin/nologin lab

COPY --chmod=0755 entrypoint.sh /usr/local/bin/lab-entrypoint.sh

USER lab
WORKDIR /home/lab

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    HOME=/tmp \
    MSF_CONFIG_PATH=/tmp/.msf4 \
    PAYLOAD_SAVE_DIR=/tmp/payloads \
    MSF_SERVER=127.0.0.1 \
    MSF_PORT=55553 \
    MSF_SSL=true

ENTRYPOINT ["/usr/local/bin/lab-entrypoint.sh"]
```

### 2. `entrypoint.sh`

The entrypoint initializes writable directories inside `/tmp`, starts the
Metasploit RPC daemon (`msfrpcd`) strictly on `127.0.0.1`, and launches the
Kali API bridge in the foreground:

```sh
#!/bin/sh
set -eu

mkdir -p /tmp/.msf4 /tmp/payloads

# Start Metasploit RPC daemon bound strictly to loopback
msfrpcd -P "${MSF_PASSWORD:?MSF_PASSWORD must be set}" \
	-U msf \
	-a 127.0.0.1 \
	-p "${MSF_PORT:-55553}" \
	-n \
	-f &

# Start the Kali API bridge on loopback
exec kali-server-mcp --ip 127.0.0.1 --port 5000
```

### 3. `compose.yaml`

The Compose definition enforces a read-only root filesystem, drops all
capabilities except those required for packet capture/scanning, caps memory and
PIDs, and mounts ephemeral `tmpfs` volumes for `/tmp` and `/run`:

```yaml
name: kali-mcp-lab

services:
  kali:
    build: .
    image: kali-mcp-lab:latest
    container_name: kali-mcp-lab
    init: true
    read_only: true
    environment:
      MSF_PASSWORD: "${MSF_PASSWORD:-change-me-lab-rpc-pass}"
    cap_drop:
      - ALL
    cap_add:
      - NET_RAW
      - NET_ADMIN
      - NET_BIND_SERVICE
    pids_limit: 1024
    mem_limit: 4g
    cpus: 2
    tmpfs:
      - /tmp:rw,exec,nosuid,nodev,size=1g
      - /run:rw,nosuid,nodev,size=32m
```

Build and start the container in the background (override `MSF_PASSWORD` in
your shell or a `.env` file):

```bash
MSF_PASSWORD="your-strong-local-rpc-password" docker compose up -d --build
```

---

## Step 2: Register the MCP Extensions in Goose

Because the container stays running in the background and inherits
`MSF_SERVER`, `MSF_PORT`, `MSF_SSL`, and `MSF_PASSWORD` from its container
environment, Goose can invoke both MCP servers on demand via `docker exec -i`.

### 1. Add the `Kali Lab` Extension

1. Open **Goose** and go to **Extensions** in the left sidebar.

2. Add a new extension with the following settings:
   * **Extension Name:** `Kali Lab`
   * **Type:** `STDIO`
   * **Command:** `docker exec -i kali-mcp-lab mcp-server`
   * **Timeout:** `300`

3. Click **Save Changes** and toggle it **On**.

### 2. Add the `MSF Lab` Extension

1. Add a second extension in **Extensions**:
   * **Extension Name:** `MSF Lab`
   * **Type:** `STDIO`
   * **Command:** `docker exec -i kali-mcp-lab metasploitmcp --transport stdio`
   * **Timeout:** `300`

2. Click **Save Changes** and toggle it **On**.

*(Note: Setting `Timeout` to `300` ensures multi-step scans or module searches
don't get cut off while your local Lemonade model processes tool outputs.)*

---

## Step 3: Verify the Lab in Goose

Open a **New Chat** in Goose (using your local Lemonade model provider) and
verify that both extensions initialize and communicate with the container:

> *"Check the health of the Kali Lab and MSF Lab extensions, list the available
> Metasploit auxiliary scanners for HTTP, and verify network interfaces inside
> the lab container."*

Goose will spawn the `STDIO` bridges inside `kali-mcp-lab`, query the local
`msfrpcd` and `kali-server-mcp` services over container loopback, and return
the results directly in your local session.
