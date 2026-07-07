---
layout: post
lang: en
ref: "building-planck-memory-systems"
title: "Building Planck #9: Memory Systems — Short-Term, Long-Term, and Why They're Different"
description: "Agents forget everything between sessions by default. Here's how to give them the right kind of memory for each problem."
handle: alex
tags: [ai, agents, memory]
series: "building-planck"
series_order: 9
published: false
---

<!-- BRIEF

## Brief metadata

- **Target audience**: Developers building AI assistants, personal tools, or long-running
  agent systems where persistence across sessions matters. They've hit the "my agent
  forgets everything" problem and want a principled solution — not a hack.
- **Core message**: Short-term and long-term memory solve fundamentally different problems;
  confusing them leads to agents that are either noisy or amnesiac.
- **Search intent**: Someone searching "AI agent persistent memory" or "how to give AI
  agent memory between sessions" wants to understand the design space, not just "store
  the conversation in a database."
- **Primary keywords**: AI agent persistent memory, LLM memory between sessions, agent memory architecture
- **Secondary keywords**: short-term memory AI, long-term memory AI, Typesense AI memory, RAG agent memory
- **Call to action**: Continue to Post #10 — Self-Improving Loops

## What to cover

- Start with the obvious limitation: by default, an agent starts every session with a
  blank slate. No memory of previous conversations, previous decisions, or previous
  mistakes. For a task-runner, that's fine. For a personal AI like Marvin, it's a
  dealbreaker.

- Distinguish two types of memory — they're often conflated but solve different problems:
  - **Short-term memory**: condensed facts about the agent itself. What it knows, its
    preferences, ongoing context about the user or project. Small, per-agent, updated
    over time. Think of it as the agent's "working knowledge."
  - **Long-term memory**: the indexed history of past conversations. Queryable, not
    injected wholesale. The agent searches it when relevant, rather than loading it all.

- Explain why injecting all history is wrong: even if you could fit 100 past conversations
  into the context window, you wouldn't want to. Most of it is irrelevant to the current
  task. Wholesale injection is noise; retrieval-based access is signal.

- Planck's implementation:
  - Short-term: one record per agent, keyed by `team_name:agent_name`, stored in
    Typesense (`short_term_memory` collection). Injected via a `before_prompt` hook
    before every turn. The agent reads it passively — it's part of the system prompt.
  - Long-term: each turn is indexed as a document in a `long_term_memory` collection.
    The `session_search` tool lets agents query it explicitly: "have I seen this before?"

- The update loop: when the short-term memory grows too large, the agent summarizes and
  overwrites it. The constraint forces concision — the agent can't keep accumulating facts
  indefinitely.

- Why this matters for Marvin specifically: Marvin's short-term memory is where your
  preferences live. Over time it learns how you like to work, what tools you use, what
  you care about. Long-term memory is the searchable record of everything you've done
  together.

- Diagram idea: two Typesense collections side by side — one with a single record per
  agent (short-term) and one with many indexed turn documents (long-term) — with arrows
  showing injection vs search access patterns.

-->
