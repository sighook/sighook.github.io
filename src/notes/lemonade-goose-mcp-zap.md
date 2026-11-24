---
title: Local AI-Assisted Traffic Analysis with OWASP ZAP, MCP, Goose, and Lemonade
description: How to build a 100% local AI-assisted traffic analysis pipeline by connecting OWASP ZAP's MCP server to Goose and a local Lemonade LLM instance.
date: 2026-11-24
note: true
root: ../
page-class: note
---

Sending target traffic, session tokens, or proprietary payloads to cloud LLM
providers is usually a non-starter during security assessments. By combining
**OWASP ZAP**, its **Model Context Protocol (MCP)** server, **Goose**, and a
local **Lemonade** inference server, you can query and analyze intercepted HTTP
history using local models with zero external data egress.

Here is the end-to-end configuration to wire the stack together.

## Prerequisites

1. **OWASP ZAP** with the **LLM** and **MCP Integration** add-ons installed
   from the ZAP Marketplace.

2. **Lemonade Server** running locally (defaulting to port `13305`) with your
   preferred local models loaded.

3. **Goose** installed locally and configured to use your local Lemonade
   endpoint as its model provider.

---

## Step 1: Connect ZAP to the Local Lemonade Server

First, retrieve the exact model IDs registered on your local Lemonade server so
ZAP's OpenAI-compatible provider knows what to call. You can list your
downloaded models via the Lemonade CLI or query its local `/v1/models` endpoint:

```sh
# Via Lemonade CLI
lemonade list --downloaded

# Or via the OpenAI-compatible REST endpoint
curl -s http://localhost:13305/v1/models | jq -r '.data[].id'
```

Next, point ZAP's native LLM integration to your local inference server:

1. Open OWASP ZAP and go to **Tools** > **Options** (`Ctrl+Alt+O`).

2. Select **LLM** in the left-hand navigation tree.

3. Under **Configured model providers**, click **Add...** (or **Modify...**) and enter:
   * **Name:** `OpenAI Compatible (Local Lemonade)`
   * **Provider:** `OpenAI Compatible`
   * **API Key:** *(Leave blank)*
   * **Endpoint Base URL:** `http://localhost:13305/v1`
   * **Models (one per line):** *(Paste the model IDs returned above — for
     example, a code-focused model for payload/script review, a reasoning
     model for multi-step logic flaws, and a fast lightweight model for quick
     triage)*
     ```text
     <your-code-analysis-model-id>
     <your-reasoning-model-id>
     <your-fast-triage-model-id>
     ```
   * **Timeout (seconds):** `60` *(Increase to `120`+ for larger 27B/30B+ parameter models).*
   * **Trusted:** Checked.

4. Click **Modify** / **Save**, then set **Default provider** to
   `OpenAI Compatible (Local Lemonade)` and choose your **Default model**
   (e.g., `Qwen3-Coder-30B-A3B-Instruct-GGUF-Q3_K_M`).

---

## Step 2: Enable MCP Integration in OWASP ZAP

To allow external AI agents like Goose to inspect ZAP's proxy history and
trigger actions, enable ZAP's built-in MCP server:

1. Still inside ZAP **Options**, select **MCP Integration** right below **LLM**.

2. Check **Enable MCP Server**.

3. Configure the listener settings:
   * **Port:** `8181`
   * **Security Key:** Click **Generate** if you plan to enforce auth headers.
   * **Require security key in Authorization header:**
     Unchecked *(for quick local loopback testing; enable this and pass an
     `Authorization` header if working on a shared host)*.
   * **Secure Only (reject HTTP connections):**
     Unchecked *(since we are connecting over local HTTP)*.
   * **Record MCP requests in ZAP history:**
     Unchecked *(keeps your proxy history clean from agent polling)*.

4. Click **OK** to apply and start the MCP server.

---

## Step 3: Add the ZAP Extension in Goose

Next, register ZAP's MCP endpoint as an HTTP extension in Goose:

1. Open **Goose** and navigate to **Extensions** in the left sidebar.

2. Click to add a new extension (or update an existing one) with the following settings:
   * **Extension Name:** `OWASP Zaproxy`
   * **Type:** `HTTP`
   * **Endpoint:** `http://localhost:8181/`
   * **Timeout:** `300` *(Gives local models plenty of time to parse large HTTP
     responses without timing out).*
   * **Request Headers:** *(Leave empty unless you enabled the Security Key
     requirement in Step 2).*

3. Click **Save Changes** and ensure the extension toggle is switched **On**.

---

## Step 4: Test Traffic Analysis in Goose

Once the extension is active, proxy a request through ZAP (via your browser or
an API client) and note its **History ID** in ZAP's **History** tab.

Open a **New Chat** in Goose and prompt the agent directly against your live
proxy session:

> *"Analyze request #42 in ZAP history. Look for interesting headers,
> authentication mechanisms, IDOR vectors, or potential injection points."*

Goose will call the ZAP MCP tools to pull the raw request and response
headers/bodies directly from your local ZAP instance and analyze them using
your local Lemonade model.
