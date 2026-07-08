---
layout: post
lang: en
ref: "building-planck-the-2080-split"
title: "Building Planck #3: The 20/80 Split — Why the Future Is Mostly Local"
description: "Frontier models are brilliant but expensive. Local models are fast and cheap but need guidance. Here's how to combine them."
handle: alex
tags: [ai, agents, local-models, self-hosting]
series: "building-planck"
series_order: 3
mermaid: true
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

You fixed the context. Now look at your bill.

Leaner prompts help — fewer tokens mean lower cost per turn. But if your agent runs
multi-step workflows, the problem compounds: an orchestrator deciding what to do, workers
executing each step, a reviewer checking quality. Every frontier model call adds up. At
scale, even a well-optimized agent gets expensive.

The temptation is to drop to a cheaper frontier tier. That helps at the margin. But it's
the wrong frame.

The question isn't **which frontier model to use**. It's: **which steps actually need one?**

Most of them don't.

## The Specification Problem

There is one thing frontier models are genuinely exceptional at: **turning ambiguous intent
into a precise, unambiguous specification**.

"Clean up the auth module." "Improve the performance of this query." "Summarize the sprint."
These are underspecified requests. Turning them into something a machine can act on reliably —
without losing the intent — requires judgment. That's where frontier intelligence earns
its cost.

Everything else is execution. Searching a codebase. Writing code to a spec. Calling an API.
Transforming data. Summarizing a result. None of these require genius. They require
**precision**. And a precise spec provides it.

> The expensive part of a workflow is knowing what to do. Doing it is mostly mechanical.

This realization changes the architecture.

## The 20/80 Split

If the hard part is specification and the rest is execution, the split becomes obvious:

- **20% frontier**: an orchestrator that reasons about the task, breaks it down, writes a
  precise spec for each step, and reviews the output.
- **80% local**: workers that execute against the spec — searching, writing, calling APIs,
  transforming data — using smaller, faster, cheaper models.

{% capture split_diagram %}
flowchart TB
    U["User request"] --> O
    subgraph F["☁️ Frontier (20%)"]
        O["Orchestrator"]
    end
    O -->|"precise spec"| W1
    O -->|"precise spec"| W2
    O -->|"precise spec"| W3
    subgraph L["🏠 Local (80%)"]
        W1["Worker"]
        W2["Worker"]
        W3["Worker"]
    end
    W1 & W2 & W3 -->|"results"| O
    O --> R["Response"]
{% endcapture %}
{% include diagram.html
   content=split_diagram
   caption="The orchestrator runs once to reason and specify. Workers run constantly to execute. Cost follows the split."
%}

The orchestrator is expensive but rare. It runs at the start of a task, at the end, and
occasionally mid-task to course-correct. The workers run constantly — and they're cheap.

A well-written spec changes what local models can do. The same model that produces mediocre
results on "refactor the auth module" will reliably handle "extract the session handling
from `user_controller.ex` into a new `Session` module, preserving the existing public
interface." The model didn't get smarter. The input did.

> The bottleneck moves from model capability to spec quality.

## Running Local in Practice

I run local models on a Framework Desktop at home — not as a hobby, but as a real part of
my workflow. Most local model servers expose an OpenAI-compatible API. Swapping a worker
from a cloud endpoint to a local one is a configuration change, not a code change.

In Planck, each agent configures its own provider independently. The orchestrator calls
Anthropic or OpenAI. The workers call a local endpoint via Ollama or llama.cpp. From the
agent's perspective, it's the same API — the routing is invisible.

> **Note**: A well-quantized 7–14B model running on consumer hardware handles most coding
> and data tasks reliably — as long as the task is well-specified. The failure mode for
> local models is ambiguity, not capability.

## Owning the Loop

Cost isn't the only reason to run local.

When you call a frontier model API, your data leaves your machine. Code, context, conversation
history — sent to a third party. Their pricing decisions affect your workflow. Their model
updates can change your agent's behavior overnight. Their rate limits cap your throughput.

When you run local, the loop closes. Data stays on your hardware. Models don't change
unless you update them. Throughput is bounded by your machine, not a provider queue.

> Self-hosting isn't a compromise. It's a strategy.

## Conclusion

In the [previous post](/building-planck-context-is-the-real-problem), we established that
context is the real bottleneck. This post adds a second constraint: not all steps in a
workflow need the same level of intelligence.

Splitting work between a frontier orchestrator and local workers isn't just a cost
optimization. It's an architectural decision that forces you to be explicit about where
judgment lives in your system — and how little of it most work actually requires.

> Most of what your agent does today could run locally. You're just not specifying precisely enough.
