---
layout: post
lang: en
ref: "building-planck-context-management-in-practice"
title: "Building Planck #8: Context Management in Practice"
description: "How Planck keeps context small, stable, and cache-friendly — and what you can steal for your own agent design."
handle: alex
tags: [ai, agents, context, llm]
published: false
---

<!-- BRIEF

## Brief metadata

- **Target audience**: Developers who have deployed AI agents and are hitting token cost
  or context limit issues in practice. They understand the theory from Post #1; now they
  want the concrete techniques. Intermediate practitioners.
- **Core message**: Treating context as first-class infrastructure — stable, predictable,
  cache-friendly — is what separates cheap, fast agents from expensive, slow ones.
- **Search intent**: Someone searching "LLM context window management techniques" or
  "reduce AI token costs in production" wants actionable patterns they can apply today,
  not more theory.
- **Primary keywords**: LLM context window management, token optimization, AI agent cost reduction
- **Secondary keywords**: prefix cache LLM, context compaction, AI session management
- **Call to action**: Continue to Post #9 — Memory Systems

## What to cover

- Revisit the premise from Post #1: context is the constraint. This post is the practical
  counterpart — not the theory, but the concrete mechanisms Planck uses to manage it.

- The compactor: when conversation history approaches 80% of the model's context window,
  Planck compacts it. The strategy is keep-recent — it preserves the last 10% of turns
  verbatim and summarizes the rest. The agent continues without interruption.

- Why 80% and not 95%: at 80% you have enough room to complete the current task without
  hitting the hard limit mid-turn. Compacting at the cliff edge is reactive; 80% is
  proactive.

- The prefix cache trick (the most underrated optimization in agent design): the system
  prompt is written once at session start and never modified. No dynamic injection, no
  rotating instructions, no "current date is X" appended on every turn. Providers cache
  the prefix — you pay full price only once per session. The savings compound over long
  sessions.

- Skill index frozen at session start: Planck loads the agent's available skills when
  the session opens and rebuilds the index only after compaction. This keeps the injected
  skill context stable between turns — another cache-friendly decision.

- Practical design rules you can apply regardless of framework:
  1. Never write the current time into the system prompt
  2. Keep tool definitions stable — tool schemas count toward context
  3. Prefer compaction over truncation (truncation loses information; compaction summarizes it)
  4. Separate what changes per turn (conversation) from what doesn't (system prompt, tools)

- Diagram idea: a session timeline showing context growth, the 80% threshold, and the
  compaction event — with a "before/after" showing what gets summarized vs kept.

- Close with: once you have stable context and a predictable compaction strategy, you can
  reason about cost and quality. Memory systems (Post #9) build directly on this foundation.

-->
