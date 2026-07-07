---
layout: post
lang: en
ref: "building-planck-building-a-team"
title: "Building Planck #12: Building a Team"
description: "How to design, configure, and run a real multi-agent team in Planck — from TEAM.json to a working workflow."
handle: alex
tags: [elixir, ai, agents, planck]
published: false
---

<!-- BRIEF

## Brief metadata

- **Target audience**: Developers who have built individual agents and are ready to
  orchestrate multi-agent workflows. They've read the previous posts or have prior
  experience with agent frameworks. They want a real, working example they can adapt.
- **Core message**: A well-configured team isn't just multiple agents — it's a careful
  assignment of responsibility, tools, and models that makes the whole greater than
  the sum of its parts.
- **Search intent**: Someone searching "multi-agent workflow tutorial" or "Planck TEAM.json
  example" wants a complete, runnable example with a real use case — not a toy demo.
- **Primary keywords**: multi-agent workflow tutorial, Planck team configuration, AI agent team
- **Secondary keywords**: TEAM.json Planck, orchestrator worker AI, AI workflow example
- **Call to action**: Continue to Post #13 — Enter Marvin

## What to cover

- This is the second hands-on post. Pick a real, useful team to build as the example —
  something like a "research team" (one orchestrator, a web researcher, a summarizer)
  or a "code review team." Keep it concrete enough to be instructive.

- Walk through `TEAM.json`: the config file that defines a team. Cover the structure:
  team name, each agent's name/model/tools/system prompt/hooks. Show the actual JSON
  for the example team.

- Explain the orchestrator/worker distinction again in practical terms: the orchestrator
  has `call_agent` in its tools list; workers don't. The orchestrator's system prompt
  tells it how to delegate. Workers' system prompts are narrow and task-specific.

- Walk through the example team executing a task: show the message flow as a Mermaid
  sequence diagram. User → orchestrator → worker A → worker B → orchestrator → user.
  Make it obvious how delegation works in practice.

- Cover system prompt design for each role:
  - Orchestrator: knows the team members, when to delegate, how to synthesize results
  - Workers: focused on their task, no awareness of the broader team structure

- Mention model selection per agent: in the example, use the orchestrator with a frontier
  model and workers with a local model to illustrate the 20/80 principle from Post #2.

- Hooks: show how to add the memory hook and skill reflector hook to an agent via
  TEAM.json. One line each — the payoff for Posts #9 and #10.

- Close with: this team is a building block. Marvin is a more complex version of this —
  multiple teams, persistent memory, a skill library that grows with use. Post #13
  puts it all together.

-->
