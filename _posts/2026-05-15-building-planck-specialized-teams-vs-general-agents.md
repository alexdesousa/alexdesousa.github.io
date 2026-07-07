---
layout: post
lang: en
ref: "building-planck-specialized-teams-vs-general-agents"
title: "Building Planck #3: Specialized Teams vs General Agents"
description: "Why one AI trying to do everything produces mediocre results — and how to design teams that don't."
handle: alex
tags: [ai, agents, teams]
published: false
---

<!-- BRIEF

## Brief metadata

- **Target audience**: Developers building or evaluating multi-agent systems who have hit
  the wall with general-purpose agents. They've tried "give it all the tools" and gotten
  mediocre, expensive results. They want a principled approach to designing better systems.
- **Core message**: Specialization through architectural constraints — not a broader system
  prompt — is what makes agent teams work.
- **Search intent**: Someone searching "multi-agent AI system design" or "AI agent
  specialization" wants a mental model for how to divide work across agents, not a
  framework tutorial.
- **Primary keywords**: multi-agent AI system, AI agent specialization, LLM orchestration
- **Secondary keywords**: agent team design, AI workflow decomposition, orchestrator worker pattern
- **Call to action**: Continue to Post #4 — Introducing Planck

## What to cover

- Open with the appeal of the general agent: "just give it all the tools and let it figure
  it out." Acknowledge why this feels right — it mirrors how we think about intelligent
  humans who can do many things.

- Show why it breaks down in practice: when an agent has 30 tools and a 10k-token system
  prompt, every turn the model attends to context that's irrelevant to the current step.
  Quality degrades. Cost climbs. Latency increases.

- Introduce the team model: instead of one agent that does everything, you have a small
  team where each member has a narrow role. The orchestrator decomposes the task and
  delegates. Workers execute with minimal, focused context.

- Key design principle in Planck: role is determined entirely by which tools an agent has.
  There's no special "orchestrator" type — an agent becomes an orchestrator the moment you
  give it the `call_agent` tool. A worker is simply an agent without that tool. The
  architecture enforces specialization without imposing it.

- Talk about the compound effect: each agent's system prompt can be kept small and stable.
  The prefix cache works. Quality is higher per step. Errors are isolated — a worker
  failure doesn't take down the whole workflow.

- Mention the human analogy: you don't hire a single contractor who does architecture,
  plumbing, and electrical. You hire specialists and a project manager. The output is
  better because each person knows exactly what they're responsible for.

- Diagram idea: contrast a single-agent setup (one box, many arrows) with a team setup
  (orchestrator + workers, clear delegation paths). Mermaid sequence diagram showing a
  task being broken down and delegated.

- Close with a forward reference: team design is the foundation. The next posts build
  the infrastructure that makes teams safe, efficient, and self-improving.

-->
