---
layout: post
lang: en
ref: "building-planck-the-2080-split"
title: "Building Planck #2: The 20/80 Split — Why the Future Is Mostly Local"
description: "Frontier models are brilliant but expensive. Local models are fast and cheap but need guidance. Here's how to combine them."
handle: alex
tags: [ai, agents, local-models, self-hosting]
series: "building-planck"
series_order: 2
published: false
---

<!-- BRIEF

## Brief metadata

- **Target audience**: Developers and engineers who are feeling the cost of frontier AI
  APIs in production workflows. Also technical decision-makers evaluating self-hosting.
  Familiar with LLMs, concerned about spend, open to alternatives.
- **Core message**: You don't need frontier models for most of your AI work — the right
  architecture cuts costs by 80% without sacrificing quality.
- **Search intent**: Someone searching "reduce LLM API costs" or "local AI models
  production" wants a concrete strategy — not just "use smaller models," but how to
  structure the work so smaller models can do it well.
- **Primary keywords**: local LLM production, self-hosting AI agents, AI cost optimization
- **Secondary keywords**: Ollama, llama.cpp, frontier vs local models, AI infrastructure cost
- **Call to action**: Continue to Post #3 — Specialized Teams vs General Agents

## What to cover

- Start from a personal angle: you run local models on a Framework Desktop at home. Not as
  a hobby — as a real part of your workflow. Establish that self-hosting is a serious
  production strategy, not a compromise.

- Introduce the cost problem with frontier models: paying per token adds up fast when agents
  run multi-step workflows. The cost doesn't scale with value — a lot of work is mechanical
  execution that doesn't need GPT-4 or Claude.

- The key insight: the expensive part of a workflow isn't execution, it's *specification*.
  A frontier model is ideal for one thing: helping a human turn their expertise into a
  precise, unambiguous spec. That spec becomes the input for everything else.

- Introduce the 20/80 architecture:
  - 20% frontier: the orchestrator reasons about the task, breaks it down, writes the spec,
    and supervises quality
  - 80% local: workers execute against the spec — searching, writing, calling APIs,
    transforming data — using smaller, faster, cheaper models

- Explain why this works: a well-written spec dramatically reduces the ambiguity that
  local models struggle with. The model doesn't need to be brilliant if the instructions
  are precise.

- Cover Planck's role: it routes requests to different providers per-agent. The orchestrator
  can use Anthropic or OpenAI; the workers can use a local model via an OpenAI-compatible
  endpoint (Ollama, llama.cpp, etc.).

- Diagram idea: a team diagram showing one frontier orchestrator and multiple local workers,
  with token costs annotated per layer.

- Close with the broader point: self-hosting isn't about avoiding cloud costs — it's about
  owning the loop. Your data stays local, your models improve with use, and you're not
  dependent on a provider's pricing decisions.

-->
