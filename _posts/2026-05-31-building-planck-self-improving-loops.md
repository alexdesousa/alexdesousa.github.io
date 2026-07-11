---
layout: post
lang: en
ref: "building-planck-self-improving-loops"
title: "Building Planck #10: Self-Improving Loops — The Skill Reflector"
description: "What if your agent could write its own playbook? Here's how Planck's skill reflector captures reusable workflows automatically."
handle: alex
tags: [ai, agents, skills]
series: "building-planck"
series_order: 10
published: false
---

<!-- BRIEF

## Brief metadata

- **Target audience**: Developers building production agent systems who want agents that
  improve with use rather than staying static. They've seen the promise of self-improving
  AI and want to see what's actually feasible today — not research paper territory.
- **Core message**: An agent that automatically captures its own successful workflows
  compounds in value over time — and it's implementable today without any ML training.
- **Search intent**: Someone searching "self-improving AI agent" or "how to make AI agent
  learn from experience" wants to see a concrete, working mechanism — not a theoretical
  discussion of fine-tuning.
- **Primary keywords**: self-improving AI agent, AI skill learning, agent reflection loop
- **Secondary keywords**: AI workflow capture, agent skill library, autonomous AI learning
- **Call to action**: Continue to Post #11 — Building a Tool

## What to cover

- Start with the problem: every time a user runs a complex multi-step workflow, the agent
  figures it out from scratch. It might take 10 tool calls to do something it has done
  20 times before. There's no learning happening — just repetition.

- Introduce skills: in Planck, a skill is a markdown file in `.planck/skills/`. It
  describes a procedure — when to use it, how to do it, what to watch out for. Before
  every session, the agent gets a skill index injected into its context. When a task
  matches a skill, the agent follows the procedure instead of reasoning from scratch.

- The skill reflector: after every agent turn that involved 5 or more tool calls, a
  background mini-agent fires automatically. It reads the conversation, checks existing
  skills, and decides: is this workflow worth capturing? If yes, it writes or updates
  a skill file.

- Walk through the loop:
  1. The user asks the agent to do something complex
  2. The agent executes it with 8 tool calls
  3. Turn ends → reflector fires in the background
  4. Reflector's mini-agent calls `list_skills` (only agent-created skills), evaluates
     the workflow, calls `write_skill`
  5. The next time the agent starts a session, the new skill is in its index

- Synthetic tool injection: when the reflector writes a skill, it injects a
  `create_skill:name` tool result into the parent agent's conversation history passively.
  The agent sees this on the next turn — a subtle signal that something was captured.

- Code example: show what a skill file looks like. The YAML frontmatter (when to use,
  always_present flag) and the procedure body.

- The self-improvement angle for Marvin: over time, Marvin's skill library grows to
  reflect your actual workflows. Not generic best practices — your specific patterns.
  The more you use it, the more efficient it becomes.

- Diagram idea: sequence diagram of the full reflector loop — user turn → reflector
  fires → mini-agent → write_skill → inject → next session loads skill.

-->
