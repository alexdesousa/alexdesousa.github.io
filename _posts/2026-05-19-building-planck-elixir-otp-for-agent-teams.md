---
layout: post
lang: en
ref: "building-planck-elixir-otp-for-agent-teams"
title: "Building Planck #5: Elixir/OTP as the Natural Runtime for Agent Teams"
description: "Most AI frameworks treat concurrency as an afterthought. Here's why the BEAM gets it right by design."
handle: alex
tags: [elixir, otp, ai, agents]
series: "building-planck"
series_order: 5
published: false
---

<!-- BRIEF

## Brief metadata

- **Target audience**: Elixir developers building AI systems who want to understand how
  OTP primitives map to agent architecture. Also developers from other languages (Python,
  Node) who are evaluating whether to switch runtimes for agent systems — they're
  frustrated with bolted-on concurrency.
- **Core message**: The BEAM's process model is exactly what multi-agent systems need —
  most frameworks reinvent it poorly, and most developers don't realise they're solving
  a distributed systems problem.
- **Search intent**: Someone searching "building AI agents in Elixir" or "Elixir GenServer
  AI agent" wants to see how OTP maps to agent concepts — not "should I use Elixir?" but
  "here's how it actually works."
- **Primary keywords**: Elixir AI agents, GenServer AI, OTP supervision AI
- **Secondary keywords**: BEAM concurrent agents, Elixir DynamicSupervisor, agent fault tolerance
- **Call to action**: Continue to Post #6 — The Sidecar Pattern

## What to cover

- Start with the observation that most AI frameworks are sequential at their core — they
  added async as an afterthought. Concurrency is a bolt-on. Agent teams are fundamentally
  concurrent distributed systems, and most frameworks pretend they're not.

- Introduce the BEAM model: every Planck agent is a GenServer under a DynamicSupervisor.
  Starting an agent is starting a process. Killing an agent is stopping a process. Teams
  are supervision trees. This isn't a metaphor — it's the actual implementation.

- Walk through the key OTP pieces that Planck uses and why each one matters:
  - `DynamicSupervisor`: agents can be started and stopped at runtime without touching
    the supervision tree definition
  - `Registry`: agents register by ID — routing a message to an agent is a registry lookup
  - `Phoenix.PubSub`: events (turn start, tool call, turn end) broadcast to subscribers
    without coupling producers to consumers
  - `:one_for_all` on the top supervisor: Registry and PubSub always restart together —
    no partial state after a crash

- Deadlock detection: when agent A calls agent B, and B calls A, you have a deadlock.
  Planck detects this by walking the Registry before the call — if the target agent is
  already in the caller's ancestry chain, it returns `{:error, :deadlock}`. This is
  free once you have a Registry; you don't need a separate cycle detector.

- Role is determined by tools: an agent becomes an orchestrator the moment it has the
  `call_agent` tool. A worker is an agent without it. There's no special type or class.
  This is the "no special X abstraction needed — it's just the BEAM" principle.

- Code example: show the agent GenServer skeleton — `start_link/1`, `handle_call` for
  synchronous tool results, `handle_cast` for streaming events. Keep it short.

- Diagram idea: Mermaid diagram of the supervision tree — top supervisor → Registry,
  PubSub, AgentSupervisor → individual agent processes.

- Close with: you get fault tolerance, isolation, hot code reloading, and distributed
  communication for free. These aren't features you added to an AI framework — they're
  the runtime you started with.

-->
