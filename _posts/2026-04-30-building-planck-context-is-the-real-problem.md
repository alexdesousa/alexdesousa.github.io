---
layout: post
lang: en
ref: "building-planck-context-is-the-real-problem"
title: "Building Planck #1: Context Is the Real Problem with AI Agents"
description: "Why giving your AI agent more context usually makes it worse — and what to do instead."
handle: alex
tags: [ai, agents, llm]
published: false
---

<!-- SERIES PLAN (full plan — include this as a brief introduction at the top of the post)

This is the opening post of "Building Planck" — a series about building a personal AI agent
that knows you, learns your patterns, and grows with you. Each post teaches one concept you
need in order to build Marvin.

Series structure:

Arc 1: The Problem Space
  1. Context Is the Real Problem with AI Agents (this post)
  2. The 20/80 Split — Why the Future Is Mostly Local
  3. General Agents vs Specialized Teams

Arc 2: The Architecture (Planck)
  4. Introducing Planck — Why I Built an AI Framework in Elixir
  5. Elixir/OTP as the Natural Runtime for Agent Teams
  6. The Sidecar Pattern — Extending Agents Without Changing the Core
  7. Agents Shouldn't Have Credentials
  8. Context Management in Practice
  9. Memory Systems — Short-Term, Long-Term, and Why They're Different
  10. Self-Improving Loops — The Skill Reflector

Arc 3: Building in Practice
  11. Building a Tool
  12. Building a Team
  13. Enter Marvin

-->

<!-- BRIEF

## Brief metadata

- **Target audience**: Developers and engineers who have built or are evaluating AI agents
  and are frustrated with inconsistent quality or high costs. Practitioners, not beginners —
  they've used LLM APIs, they understand tokens, they've hit context limits.
- **Core message**: The quality gap in your AI agent is almost always a context problem,
  not a model problem.
- **Search intent**: Someone searching "why are my AI agents producing bad results" or
  "how to improve AI agent quality" wants to understand the root cause — not a list of
  prompting tips, but an architectural insight they haven't considered.
- **Primary keywords**: AI agent context window, LLM context management, AI agent quality
- **Secondary keywords**: prefix cache, context window optimization, LLM token cost
- **Call to action**: Continue to Post #2 — The 20/80 Split

## What to cover

- Open with the uncomfortable truth: the bottleneck in AI agents is not model intelligence —
  it's context. Everything that makes an agent slow, expensive, or mediocre traces back to
  poor context decisions.

- Explain what context actually is in practice: the conversation history, system prompt,
  tool definitions, and injected knowledge that the model sees on every turn. It's finite,
  it's expensive, and most frameworks treat it as an afterthought.

- Talk about the prefix cache: if the system prompt stays stable, the LLM provider caches
  it and you pay almost nothing to reuse it. The moment you modify the system prompt mid-session
  (injecting dynamic state, rotating instructions), you invalidate the cache and pay full price
  every turn. This is a hidden tax that adds up fast.

- Introduce the generalist trap: giving an agent a broad system prompt and a large toolset
  feels productive — the agent can "do anything." In practice it produces average results
  because the model spends attention on irrelevant context. A narrowly scoped agent with
  a small, stable system prompt consistently outperforms a generalist with more context.

- Frame specialization as an architectural decision, not a prompt trick. The right response
  to "this agent isn't good enough" is usually "reduce what it sees," not "add more
  instructions."

- Diagram idea: show a wide-context generalist vs a narrow-context specialist side by side,
  illustrating what each model "sees" on a turn and what fraction is relevant.

- Close by setting up the rest of the series: if context is the constraint, every subsequent
  post is about managing it deliberately — through team design, memory, skills, local models,
  and the sidecar pattern.

-->
