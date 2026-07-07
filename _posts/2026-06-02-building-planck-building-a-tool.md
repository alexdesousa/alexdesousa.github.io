---
layout: post
lang: en
ref: "building-planck-building-a-tool"
title: "Building Planck #11: Building a Tool"
description: "A step-by-step walkthrough of building a custom Planck tool — from behaviour to sidecar registration."
handle: alex
tags: [elixir, ai, agents, planck]
published: false
---

<!-- BRIEF

## Brief metadata

- **Target audience**: Developers ready to start building with Planck who want hands-on
  guidance. They've read the conceptual posts and want to write code. Elixir familiarity
  assumed but not deep expertise.
- **Core message**: A Planck tool is just a module — once you understand the interface,
  your entire integration landscape becomes agent-accessible.
- **Search intent**: Someone searching "how to build Planck agent tool" or "custom tool
  AI agent Elixir tutorial" wants a complete, working example they can copy and adapt —
  not a conceptual overview.
- **Primary keywords**: Planck tool tutorial, Elixir AI tool, custom AI agent tool
- **Secondary keywords**: AI tool development, agent tool schema, Planck sidecar tool
- **Call to action**: Continue to Post #12 — Building a Team

## What to cover

- Frame this as the practical bridge between concepts and building. Posts 1-10 explained
  the ideas; this post gets hands-on.

- What a tool is in Planck's model: a module that implements `Planck.Agent.Tool`. The
  agent calls it by name; Planck routes the call to the sidecar; the sidecar module
  executes and returns a result. The agent never knows about the implementation.

- Walk through building a concrete, useful tool end-to-end. Choose something relatable
  — a good candidate would be a "read URL and summarize" tool or a simple "search
  calendar" tool. Keep it realistic but not trivial.

- Cover:
  1. Defining the tool schema (name, description, parameters — this is what the model sees)
  2. Implementing the `call/1` function
  3. Registering the tool in the sidecar
  4. Writing a test

- Emphasize the schema as the interface: the description and parameter names are what the
  model uses to decide when and how to invoke the tool. Bad descriptions = the model
  calls the tool at the wrong time. Good descriptions = the model uses the tool correctly
  without additional prompting.

- Code walkthrough: full module with comments. Show the behaviour, the schema, the
  implementation, and the test side by side.

- Diagram idea: Mermaid sequence diagram — agent decides to call a tool → sidecar
  receives the call → tool module executes → result returned to agent.

- Close with: once you can build tools, the sidecar becomes your personal integration
  layer. Any API, any data source, any local service — wrap it in a tool and your agents
  can use it. Post #12 shows how to put tools together into a team.

-->
