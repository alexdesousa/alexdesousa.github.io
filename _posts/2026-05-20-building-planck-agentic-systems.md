---
layout: post
lang: en
ref: "building-planck-agentic-systems"
title: "Building Planck #6: Building Your Own Agentic System with planck_headless"
description: "planck_cli is just one app built on planck_headless. Here's how to embed the same agent runtime into your own Elixir codebase — and the small example app we'll keep extending for the rest of this series."
handle: alex
tags: [elixir, ai, agents, planck_headless]
series: "building-planck"
series_order: 6
published: false
---

<!-- BRIEF

## Brief metadata

- **Target audience**: Elixir developers who want multi-agent capability inside an existing
  app or a new one, without adopting Planck's own Web UI or Docker stack. Comfortable with
  Elixir/OTP basics; hasn't necessarily read the OTP-internals-heavy posts.
- **Core message**: `planck_headless` is the exact same engine `planck_cli` runs on — a
  clean, dependency-injectable core where almost everything you need is three functions.
  Building on it is a dependency, not a fork.
- **Search intent**: Someone searching "add AI agents to Elixir app" or "planck_headless
  tutorial" wants a working, minimal integration example — not more architecture theory,
  they got that in earlier posts.
- **Primary keywords**: Elixir AI agent library, planck_headless tutorial, embed AI agent Elixir
- **Secondary keywords**: multi-agent Elixir, OTP AI agent runtime, Elixir agent integration
- **Call to action**: None specific — the only other post still planned in the series is
  "Enter Marvin" (still being built; no fixed number or date yet).

## What to cover

- Reframe `planck_cli`: it isn't "the Planck app" — it's one app built on `planck_headless`,
  a Phoenix web UI and HTTP API written as internal modules on top of the exact same public
  API anyone else can depend on. `planck_cli` never calls `planck_agent` directly; neither
  should you.

- The whole public surface, shown as one worked example, not a reference dump:
  `Planck.Headless.start_session/1` (team via alias, path, or `nil` for a default dynamic
  team), `Planck.Headless.prompt/2`, `Phoenix.PubSub.subscribe/2` on `"session:#{id}"`, and
  `Planck.Headless.close_session/1`. If you can call four functions and pattern-match on
  `{:agent_event, type, payload}`, you can build on Planck.

- Build a genuinely minimal example, live in the post: a toy web app — a holiday destination
  finder. No Phoenix, no database: just Plug + Bandit and a single HTML page using
  Server-Sent Events to stream the agent's responses into the browser, the same three-call
  loop (`start_session/1`, `prompt/2`, PubSub subscribe) `planck_cli`'s chat panel is built on,
  just without the rest of the product around it.

  - An **orchestrator** interviews the visitor conversationally (preferred climate, trip vibe,
    region, trip length), picks a handful of candidate cities from its own knowledge, then
    delegates verification to two workers.
  - A **weather worker** (`get_weather/1`) backed by Open-Meteo's free, keyless geocoding and
    forecast APIs — confirms whether each candidate's weather actually matches what was asked
    for right now.
  - A **facts worker** (`get_country_facts/1`) backed by REST Countries' free, keyless API —
    surfaces currency, language, and region so the orchestrator can caveat the recommendation.
  - The orchestrator synthesizes a final recommendation citing what the workers actually
    found — real HTTP calls against real APIs, no dummy data, no API keys required to run it.
  - Natural, no-extra-explanation callback to the model-routing constraint from earlier posts:
    the workers are pure tool-calling glue and can run on a cheap/fast model; the orchestrator
    is doing the actual conversation and synthesis, so it gets the better one.

- Name explicitly what you get for free just by depending on `planck_headless`, that you did
  NOT have to build: session persistence (SQLite), team loading from `TEAM.json`, config
  resolution (providers, models, API keys), and the whole PubSub event stream. None of that
  gets reimplemented — it's the same engine.

- Say where this example app actually lives: `planck_headless/examples/` (new folder in the
  repo) — a real, runnable reference in the repo, not just a blog snippet.

- Diagram idea: two boxes side by side, `planck_cli` and "your app," both sitting on top of
  one shared `planck_headless` box — the visual version of "you're not forking anything."

- Close with: once your own app can start a session and stream its events, everything from the
  earlier posts — the sidecar, tools, memory, widgets — is already available to you too.
  Not using `planck_cli` doesn't lock you out of any of it.

-->
