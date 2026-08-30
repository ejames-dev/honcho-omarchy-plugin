# Honcho — Omarchy bar widget

Shows whether a local [Honcho](https://honcho.dev) instance (the self-hosted
memory server for AI agents) is reachable. Polls its `GET /health` endpoint
every 15 seconds and on panel open; the bar pill flags red when the server
isn't reachable.

This widget only checks reachability — it does not read or display any
workspace, session, or memory content.

## Prerequisites

A Honcho server running locally, e.g. via its own `docker compose up -d`
setup (see [honcho's docs](https://docs.honcho.dev)). By default the API
binds to `http://localhost:8000`.

## Install

```sh
omarchy plugin add https://github.com/ejames-dev/honcho-omarchy-plugin --enable
```

## Configure

If your Honcho instance runs on a different host or port, set:

```sh
export OMARCHY_HONCHO_URL=http://localhost:9000
```

before the Omarchy shell starts (e.g. in your shell profile or a systemd
user environment file). The widget defaults to `http://localhost:8000`.

## Uninstall

```sh
omarchy plugin remove io.github.ejames-dev.honcho
```

## Security notes

- Makes a single `GET <url>/health` request on a 2-second timeout — no
  writes, no credentials, no data beyond the URL you configure.
- The default URL is loopback-only (`localhost`). If you override it to a
  non-loopback host, that request goes wherever you point it — only do
  this if you trust that endpoint.
- No external dependencies beyond `curl`, which ships with Omarchy.
