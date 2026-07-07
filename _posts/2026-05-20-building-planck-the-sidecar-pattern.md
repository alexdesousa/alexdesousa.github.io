---
layout: post
lang: en
ref: "building-planck-the-sidecar-pattern"
title: "Building Planck #6: The Sidecar Pattern — Extending Agents Without Changing the Core"
description: "How Planck separates agent intelligence from tooling — and why that separation matters for everything that follows."
handle: alex
tags: [ai, agents, architecture, elixir]
published: false
---

<!-- BRIEF

## Brief metadata

- **Target audience**: Developers building agent systems who want to add custom tools or
  integrations without coupling everything together. Architects thinking about long-term
  maintainability of agent-based applications. Intermediate to advanced.
- **Core message**: Separating tool execution from agent intelligence makes your system
  safer, more testable, and extensible without touching the core.
- **Search intent**: Someone searching "how to add custom tools to AI agent" or "AI agent
  extensibility pattern" wants an architectural answer — a pattern they can apply regardless
  of framework, not a library-specific how-to.
- **Primary keywords**: AI agent tools architecture, sidecar pattern AI, custom agent tools
- **Secondary keywords**: Erlang distributed nodes, AI tool integration, agent extensibility
- **Call to action**: Continue to Post #7 — Agents Shouldn't Have Credentials

## What to cover

- Explain the problem the sidecar solves: if tools are baked into the agent framework,
  every new tool requires updating the framework. More importantly, tools often need
  stateful processes, external dependencies, and full test coverage — things that don't
  belong in a core agent library.

- What the sidecar is: a separate Erlang node connected via distributed Erlang (`:rpc`).
  The sidecar can be anything — a full Phoenix application with a database, or a single
  GenServer module. The connection is just `:rpc.call/4`.

- The key design decision: the agent framework (Planck) doesn't know what tools exist.
  At startup, the sidecar registers its tools. The agent discovers them at session start.
  New tools appear without restarting the agent.

- Walk through what Planck's bundled sidecar actually includes: workspace search
  (Typesense), web search (Searxng), document extraction (Tika), web fetch, memory,
  and agent-vault. These are all running as supervised processes inside the sidecar node.

- The `local_or_hex` pattern: if you're running in the Planck monorepo, the sidecar
  uses the local `planck_agent` package. If you're deploying standalone, it falls back
  to the Hex package. The sidecar works in both environments transparently.

- Code example: show what a sidecar tool module looks like — the behaviour, a `call/1`
  function, how it's registered. Keep it to one concrete, simple tool.

- Diagram idea: Mermaid diagram showing the two Erlang nodes — the Planck node and the
  sidecar node — with the RPC boundary between them, and tool registration/discovery flow.

- Close with: the sidecar pattern is what makes agent-vault, memory, and the skill
  reflector possible without coupling them to the agent core. The next posts build
  directly on it.

-->
