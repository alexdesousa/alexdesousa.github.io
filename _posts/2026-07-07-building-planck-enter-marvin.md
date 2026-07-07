---
layout: post
lang: en
ref: "building-planck-enter-marvin"
title: "Building Planck #13: Enter Marvin"
description: "Putting it all together: a personal AI agent with its own team, persistent memory, and a self-improving skill library."
handle: alex
tags: [ai, agents, planck, marvin]
published: false
---

<!-- BRIEF

## Brief metadata

- **Target audience**: Readers who have followed the series and are ready to build.
  Also anyone who landed here directly searching for personal AI — they'll need enough
  context to understand the architecture without having read every previous post.
- **Core message**: Marvin isn't a product — it's what emerges when you combine context
  discipline, memory, and self-improvement in service of one person's specific work.
- **Search intent**: Someone searching "build personal AI assistant self-hosted" or
  "AI agent that learns about you" wants to see what's actually possible with current
  technology — a concrete, working architecture, not a vision statement.
- **Primary keywords**: personal AI assistant self-hosted, AI agent that learns, custom personal AI
- **Secondary keywords**: Marvin AI, self-hosted AI assistant, personal AI agent architecture, Planck Marvin
- **Call to action**: Try Planck — link to GitHub and getting started guide

## What to cover

- This is the culminating post. Open by acknowledging that every previous post was a
  building block for this one. Marvin isn't a single agent — it's an architecture.

- Define what Marvin is: a personal AI that:
  - Has a team of specialized sub-agents for different task types (writing, coding,
    research, calendar management, etc.)
  - Learns your preferences and patterns via short-term memory
  - Builds a searchable history of everything you've worked on together via long-term memory
  - Writes its own skills from your workflows via the skill reflector
  - Routes credentials securely through agent-vault
  - Runs on local models for most tasks, with frontier model access when needed

- Walk through Marvin's full TEAM.json: the orchestrator and each specialist. Show
  the actual configuration. Explain why each agent has the tools and hooks it does.

- Explain the "knowing you" loop:
  1. You ask Marvin something
  2. The orchestrator routes it to the right specialist
  3. The specialist executes with memory of previous similar tasks
  4. After the turn, the skill reflector evaluates and possibly writes a skill
  5. Short-term memory is updated with anything new learned about your preferences
  6. Next time you ask something similar, Marvin is faster and more accurate

- Address the local-first reality: most of Marvin's work happens on your own hardware.
  The skill library is on your machine. The memories are in your local Typesense.
  The credentials never leave your network. You own the loop.

- Reflect on the journey: you built Planck to learn how to build agent workflows
  efficiently. Marvin is the answer to the question you started with — not an
  all-knowing AI, but an AI that knows *you* specifically, that amplifies your
  expertise rather than replacing it.

- Close with the open question: Marvin is not finished. It's a system that grows with
  use. The more you use it, the more it learns. That's the point.

- (Optional) Include a short section on where to go from here: the Planck GitHub,
  how to get started, how to follow along as Marvin evolves.

-->
