---
layout: post
lang: en
ref: "building-planck-the-20-80-split"
title: "Building Planck #3: The 20/80 Split: Why the Future Is Mostly Local"
description: "Frontier models are brilliant but expensive. Local models are fast and cheap but need guidance. Here's how to combine them."
handle: alex
image: pareto.jpg
image_author: "Austin Distel"
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

We fixed the context. Now look at our bill.

We have [optimized teams of agents](/building-planck-specialized-teams-vs-general-agents) working. Quality is good, but it's getting expensive
fast. Faced with that cost, we try to drop to cheaper frontier models at the expense of quality.
But that's the wrong approach.

The question isn't **which frontier model to use**. It's: **which steps actually need one?**

> Most of them don't.

## The Specification Problem

There is one thing frontier models are genuinely exceptional at: **turning ambiguous intent
into a precise, unambiguous specification**.

"Clean up the auth module." "Improve the performance of this query."
"Write a blog post about AI." These are underspecified requests. We need some brainstorming, 
follow-up questions and judgment to get there. Frontier models excel at this.

Once the specification is clear, execution doesn't need a high level of intelligence. It just
needs a model that knows how to follow instructions.

> The expensive part of a workflow is _knowing what to do_. _Doing it_ is mostly mechanical.

This realization changes the architecture.

## The 20/80 Split

The numbers echo the Pareto principle{% include cite.html title="Pareto Principle" url="https://en.wikipedia.org/wiki/Pareto_principle" %}: a small fraction of inputs drives the majority of
outcomes. Specification is that fraction.

- **20% frontier**: an orchestrator that reasons about the task, breaks it down, writes a
  precise spec for each step, and reviews the output.
- **80% local**: workers that execute against the spec: searching, writing, calling APIs,
  transforming data using smaller, faster, cheaper models.

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

The orchestrator is expensive, but runs less frequently. It runs at the start of a task,
at the end, and occasionally mid-task to course-correct.

The workers run constantly and they're cheap.

A well-written spec changes what local models can do. The same model that produces mediocre
results on `"refactor the auth module"` will reliably handle:

```
Extract the session handling from `user_controller.ex` into a new `Session` module,
preserving the existing public interface.
```

> The model didn't get smarter. The input did.

## Running Local in Practice

I run local models on a [Framework Desktop](https://frame.work/es/en/desktop) at home. Though
it started as a hobby, these models became part of my workflows.

I still use frontier models for specifications. They're awesome at that job. But my local
models can follow these specifications almost flawlessly, for next to nothing.

This is why [Planck](https://thebroken.link/planck) supports both frontier and local models
natively. I've seen the 20/80 split match frontier-only quality in my own AI teams.
I've gotten good quality at a fraction of the cost.

## Owning the Loop

Cost isn't the only reason to run local though.

Some of the models I run locally are also decent at specifications for certain tasks. They're
slow, but they get the job done with the right context. That lets some workflows run
**entirely local**.

When we call a frontier model API, our data leaves our machine. Code, context, conversation
history... all sent to a third party. Their pricing decisions affect our workflow. Their model
updates can change our agent's behavior overnight. Their rate limits cap our throughput.

When we run local, data stays on our hardware. The pricing is predictable as electricity is
the main cost. Models don't change unless we update them. Throughput is bounded by our machine, 
not a provider queue.

> Depending on the hardware, it could even be environmentally friendly.{% include cite.html title="Framework Desktop: A Deep Dive Into Power & Thermals" url="https://www.phoronix.com/review/framework-desktop-power/5" %}{% include cite.html title="Minimum Power Draw – Idle (Framework Community)" url="https://community.frame.work/t/minimum-power-draw-idle/70184" %}{% include cite.html title="Framework Sustainability" url="https://frame.work/sustainability" %}

## Conclusion

The [previous post](/building-planck-specialized-teams-vs-general-agents) gave us the team
model. This post adds the cost dimension: not every step needs a frontier model, and knowing
which steps do is most of the architectural work.

[Planck](https://thebroken.link/planck) supports this natively. Each agent in a team
configures its own model provider independently. The orchestrator can call a frontier API
while workers call a local endpoint. The team doesn't need to change.

In the [next post](/building-planck-introducing-planck), we introduce Planck properly: what
it is, how it works, and how context, specialization, and model routing come together in a
single system.

> Frontier for thinking. Local for doing.

## References

{% include references.html %}
