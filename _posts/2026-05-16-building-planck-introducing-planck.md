---
layout: post
lang: en
ref: "building-planck-introducing-planck"
title: "Building Planck #4: Introducing Planck — Why I Built an AI Framework in Elixir"
description: "Planck is an open-source AI agent framework built on Elixir/OTP. Here's why BEAM processes are the natural unit of an AI agent."
handle: alex
tags: [elixir, ai, agents, planck]
series: "building-planck"
series_order: 4
published: false
---

<!-- BRIEF (Elixir newsletter anchor — introduce all series themes through Planck)

## Brief metadata

- **Target audience**: Two audiences: (1) Elixir developers curious about AI agent frameworks;
  (2) AI developers evaluating framework options who are open to Elixir. Both groups are
  technically sophisticated. The Elixir developer wants validation that their language is
  the right tool; the AI developer wants to be surprised by something they hadn't considered.
- **Core message**: Elixir/OTP is the natural runtime for AI agent teams — and Planck is
  the proof of concept.
- **Search intent**: Someone searching "Elixir AI agent framework" or "build AI agents
  Elixir" wants to know if there's a serious, maintained option — not a toy project.
- **Primary keywords**: Elixir AI agents, Planck framework, OTP multi-agent
- **Secondary keywords**: Elixir LLM, BEAM AI, self-hosted AI framework
- **Call to action**: Star Planck on GitHub / continue to Post #5

## What to cover

- The name: Planck is named after the Planck length — the smallest meaningful distance.
  The philosophy: agents should be as small as meaningful. Each one does exactly one thing.

- Why Elixir: you've been writing Elixir for years. When you started thinking seriously
  about agent frameworks, the answer was obvious — agents are concurrent processes that
  send messages to each other, fail independently, and need supervision. That's what the
  BEAM was designed for. You weren't bolting concurrency onto a sequential runtime; you
  were using the right tool.

- What Planck is: a monorepo of packages (`planck_ai`, `planck_agent`, `planck_cli`,
  `planck_headless`, `planck_docker`) that together form a self-hostable AI agent platform.
  Each agent is a BEAM process. Teams are supervision trees. Inter-agent communication is
  message passing.

- Introduce the sidecar: Planck agents don't hardcode tools — they connect to a sidecar
  node at runtime. The sidecar is a separate Erlang node that can be anything: a full
  Phoenix app, a single module. This is how you extend agents without modifying the core.

- Touch on memory: short-term memory (per-agent condensed facts) and long-term memory
  (indexed conversation history). Each agent can have both injected before every turn.

- Touch on skills: agents can write their own skills — reusable procedures captured in
  markdown — via a self-improvement loop that fires automatically after complex turns.

- Touch on the 20/80 split: Planck supports any provider. The orchestrator can use
  a frontier model; workers can use local models on your own hardware.

- Touch on agent-vault: agents never hold API credentials. An HTTPS MITM proxy intercepts
  outbound calls and injects credentials transparently. The agent just makes the call.

- Frame the series: this is the map for everything that follows. Each of the remaining
  posts goes deep on one of these concepts. By the end of the series, you'll have
  everything you need to build Marvin — a personal AI that knows you, grows with you,
  and gets better over time.

- Include a brief series index with links to all posts (can be updated as posts publish).

-->
