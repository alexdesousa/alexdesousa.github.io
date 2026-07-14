---
layout: post
lang: en
ref: "building-planck-introducing-planck"
title: "Building Planck #4: Introducing Planck, an Agent Harness in Elixir"
description: "Three constraints shaped Planck: context, specialization, and model cost. Here is what an AI agent framework looks like when you build on OTP."
handle: alex
image: distance.jpg
image_author: "Ryunosuke Kikuno"
tags: [elixir, ai, agents, planck]
series: "building-planck"
series_order: 4
mermaid: true
published: true
---

The first three posts in this series each identified a constraint:

1. Context is quadratically expensive. Keep it small.
2. One agent cannot focus on everything. Build a team.
3. Most steps don't need the most advanced model. Route accordingly.

Those three constraints shaped [Planck](https://thebroken.link/planck).
The framework doesn't enforce them, but its structure nudges you toward all three.

## The Harness

If the model is the brains and context is the memory, the harness is the body. It gives
the model a way to act: read files, call APIs, run commands, delegate to other agents.

{% capture harness_diagram %}
flowchart LR
    subgraph Agent["Agent = model + context + harness"]
        M["Model\n(reasons)"]
        C["Context\n(sees)"]
        H["Harness\n(acts)"]
        H -->|"assembles"| C
        C --> M
        M -->|"tool calls"| H
    end
    W["World\n(files · APIs · shell)"]
    H -->|"executes"| W
    W -->|"results"| H
{% endcapture %}
{% include diagram.html
   content=harness_diagram
   caption="The harness assembles context, feeds it to the model, and executes what the model returns."
%}

## The Name

Planck is named after the Planck length, the smallest meaningful distance in physics. The
philosophy transfers: **agents should be as small as meaningful**. One job, one system prompt,
one focused tool list. A team of specialized agents.

## The Language

Agents are concurrent processes that send messages to each other, fail independently, and
need supervision. That is exactly what the BEAM was designed for. The EVM handles tens of
thousands of lightweight processes natively, with built-in message passing, fault isolation,
and supervision trees.

With all those features covered in the runtime, I only needed to implement the agent logic.

> An AI agent team is a supervision tree. Each agent is a process.

## The Foundations

Planck is organized as three libraries that can be used independently or composed together.
The monorepo also ships [`planck_cli`](https://github.com/alexdesousa/planck/tree/main/planck_cli),
a complete web agent harness built on the three libraries.

{% capture stack_diagram %}
flowchart TB
    CLI["planck_cli\n(App: Web UI + HTTP API)"]
    HL["planck_headless\n(Lib: Sessions · Config · Teams · Sidecar)"]
    AG["planck_agent\n(Lib: Agent processes · PubSub · Tools)"]
    AI["planck_ai\n(Lib: LLM abstraction · Streaming · Models)"]
    SC["Sidecar\n(App: Custom tools)"]

    CLI --> HL
    HL --> AG
    AG --> AI
    HL -. connects .-> SC
{% endcapture %}
{% include diagram.html
   content=stack_diagram
   caption="Each library has a single responsibility. Sidecar tools extend the pool without touching the core."
%}

- [`planck_ai`](https://github.com/alexdesousa/planck/tree/main/planck_ai) is the LLM abstraction
  layer. Built on top of [`req_llm`](https://github.com/agentjido/req_llm),
  it provides typed structs, a streaming event protocol, and a provider-agnostic API that
  speaks to Anthropic, Google and any OpenAI-compatible endpoint.
- [`planck_agent`](https://github.com/alexdesousa/planck/tree/main/planck_agent) is the agent
  core. Each agent is a `GenServer` that manages its own conversation history,
  handles tool calls, and publishes events over Phoenix `PubSub`.
- [`planck_headless`](https://github.com/alexdesousa/planck/tree/main/planck_headless) is
  the application layer. It owns configuration (from JSON files,
  environment variables, or application config), loads resources at startup
  (teams, skills, models), manages session lifecycles, and handles the
  optional sidecar connection.

`planck_headless` also supports the sidecar: an optional app that adds custom tools without
touching the core libraries (more on that later).

## The Principles

In a Planck team definition, we can see the three principles in action. A team lives in a
directory under `.planck/teams/`. The `TEAM.json` file declares its members:

```json
{
  "name": "dev-team",
  "description": "A planner, builder, and reviewer for software tasks.",
  "members": [
    {
      "type":          "orchestrator",
      "provider":      "anthropic",
      "model_id":      "claude-sonnet-4-6",
      "system_prompt": "members/orchestrator.md",
      "tools":         ["read", "list_team", "call_agent", "interrupt_agent"]
    },
    {
      "type":          "planner",
      "provider":      "anthropic",
      "model_id":      "claude-opus-4-8",
      "system_prompt": "members/planner.md",
      "tools":         ["read", "write", "edit", "respond_agent"]
    },
    {
      "type":          "builder",
      "provider":      "local_gemma",
      "model_id":      "gemma-4-12b",
      "system_prompt": "members/builder.md",
      "tools":         ["read", "write", "edit", "bash", "respond_agent"],
      "skills":        ["elixir-dev"]
    },
    {
      "type":          "reviewer",
      "provider":      "local_qwen",
      "model_id":      "qwen3.6-27b",
      "system_prompt": "members/reviewer.md",
      "tools":         ["read", "send_agent", "respond_agent"]
    }
  ]
}
```

Each agent has:

1. Their own system prompt, tools and skills:
   [keep context small](/building-planck-context-is-the-real-problem),
2. Their own clear role within the workflow:
   [build a specialized team](/building-planck-specialized-teams-vs-general-agents),
3. Their own model, matched to how much reasoning the step actually needs:
   [route accordingly](/building-planck-the-20-80-split).

> We can't prompt our way around a missing tool. And we can't accidentally grant one.

## The Tools

Planck has several built-in tools, organized in four categories: basic tools,
inter-agent tools, skill tools, and informational tools.

### Basic Tools

They are the basic tools an agent needs to interact with its environment:

- `read`: reads files with offset and limit support
- `write`: creates or overwrites files
- `edit`: replaces exact strings; the surgical alternative to rewriting
- `bash`: runs shell commands, with process group cleanup on timeout

### Inter-agent Tools

Inter-agent tools are how agents talk to each other. They are the mechanism behind the
team model:

- `call_agent`: sends a synchronous message from a delegator agent to a target
  agent. The target agent calls `respond_agent` when done.
- `send_agent`: sends an asynchronous message from a delegator agent to a target
  agent. The target also calls `respond_agent` when done. This will trigger a new turn
  in the delegator agent if it ended its previous turn.
- `respond_agent`: the target agent responds to the delegator agent.
- `spawn_agent`: creates a new worker at runtime with a given model, role,
  system prompt, and tool list. The team can grow dynamically without restarting.
- `destroy_agent`: terminates an agent permanently and removes it from the team.
- `interrupt_agent`: aborts an agent's current turn without terminating it. The
  agent stays alive and returns to idle.

### Skill Tools

A skill is a reusable markdown file an agent can load on demand: a rubric, a style guide,
a set of procedures. When skills are configured, two tools are injected automatically
without any `TEAM.json` declaration:

- `load_skill`: loads a skill's full instructions by name. Every agent gets this
  automatically.
- `list_skills`: lists all available skills in the pool. Orchestrators get this
  automatically; workers opt in by declaring it in their `"tools"` array.

### Informational Tools

- `list_team`: returns all agents in the team with their type, name, description, and
  status. Pass `verbose: true` to also get tool names and model per member, useful when
  reasoning about which worker to delegate a task to.
- `list_models`: returns all configured and connected models available for spawning
  agents, including provider, context window, and base URL.

## The Events

Planck's communication model has two layers.

**Between agents**, all communication is message passing via
[the inter-agent tools](#inter-agent-tools).

**Between Planck and the outside world**, communication is events. Every agent
publishes to a PubSub topic. Any process that subscribes gets a real-time stream:

```elixir
{:ok, session_id} = Planck.Headless.start_session(template: "dev-team")

Phoenix.PubSub.subscribe(Planck.Agent.PubSub, "session:#{session_id}")

Planck.Headless.prompt(session_id, "Refactor lib/auth.ex into a separate module")

receive do
  {:agent_event, :text_delta, %{text: chunk}} -> IO.write(chunk)
  {:agent_event, :turn_end, _}                -> :done
end
```

The subscriber never reaches into agent internals. It sends a prompt and listens for
events: `:text_delta`, `:turn_start`, `:turn_end`, `:tool_start`, `:tool_end`,
`:usage_delta`, `:worker_spawned`.

## The Sidecar

The built-in tools cover the basics. Custom tools live in a sidecar: a separate Elixir/OTP
application that connects over distributed Erlang. Database queries, API calls, specialized
analyzers: anything the core doesn't ship with.

The sidecar implements one callback:

```elixir
defmodule MySidecar.Planck do
  use Planck.Agent.Sidecar

  @impl true
  def tools do
    [
      Planck.Agent.Tool.new(
        name: "run_tests",
        description: "Run the test suite and return output.",
        parameters: %{
          "type" => "object",
          "properties" => %{
            "timeout_ms" => %{
              "type"        => "integer",
              "description" => "Max milliseconds to wait (default 300000)"
            }
          }
        },
        execute_fn: fn _agent_id, _id, args ->
          timeout = Map.get(args, "timeout_ms", 300_000)
          case System.cmd("mix", ["test"], timeout: timeout) do
            {output, 0} -> {:ok, output}
            {output, _} -> {:error, output}
          end
        end
      )
    ]
  end
end
```

When Planck starts, it connects to the sidecar node and calls `list_tools/0`. The returned
tools are loaded into the resource pool and available to any agent that declares them. The
sidecar can be as minimal as a single module or as rich as a full Phoenix application with
its own database connection, supervision tree, and tests.

The sidecar also provides hooks: lifecycle callbacks implemented in the sidecar.

- `prompt_hook`: declared per-agent; runs before each LLM turn
- `turn_end_hook`: declared per-agent; runs after each LLM turn
- `compactor`: runs for all agents automatically; can be overridden per-agent in `TEAM.json`

Tools extend what an agent can do. Hooks extend how it behaves.

The core library does not change regardless.

> The sidecar is the extension point. The harness is the stable surface.

## The ~~CLI~~ Web UI

I considered a TUI when starting the CLI harness. A terminal interface felt natural for a
coding agent. But I didn't want just a coding agent. I wanted a team of agents for different
tasks.

I wanted to have a better way to access it. A web UI allows me to host it on a server and reach
it from any device with a browser. I no longer need to be in my shell. I can be on my phone,
on my tablet, on a random toaster screen.

A Phoenix LiveView application handles Markdown rendering, syntax-highlighted code blocks,
streaming text, and a real-time sidebar showing each agent's token usage and cost.

The same Phoenix app also serves an HTTP/SSE API at `/api`. Any process that can make an
HTTP request or consume a Server-Sent Events stream gets full access to the session.

```
GET  /api/sessions              # list all sessions
POST /api/sessions              # start a session
POST /api/sessions/:id/prompt   # send a prompt
GET  /api/sessions/:id/events   # SSE event stream
(...)
```

This API allows users to control Planck with other agent harnesses e.g., Claude Code could
control a full Planck team remotely.

## The Configuration

Planck reads configuration from `.planck/config.json`. A minimal setup declares a
provider and at least one model alias:

```json
{
  "default_model": "sonnet",
  "providers": {
    "anthropic": { "type": "anthropic" }
  },
  "models": [
    { "id": "sonnet", "model": "claude-sonnet-4-6", "provider": "anthropic" }
  ]
}
```

API keys go in `.planck/.env` (project-local) or `~/.planck/.env` (global):

```sh
ANTHROPIC_API_KEY=sk-ant-...
```

Teams live under `.planck/teams/`, skills under `.planck/skills/`, the sidecar under
`.planck/sidecar/`. Planck loads them all at startup.

The [`planck_setup`](https://github.com/alexdesousa/planck/tree/main/skills/planck_setup)
skill is available as a standalone download and is included in the Docker bundle (more
on that in the next post). Install it under `.planck/skills/` and any agent in any
session can load it for the full configuration reference: providers, models, teams,
sidecars, hooks, and the HTTP API.

## The Conclusion

The previous three posts described three independent constraints. Planck is where they
connect: small agents with focused context, organized into specialized teams, routing each
step to the right model.

[`planck_ai`](https://hex.pm/packages/planck_ai), [`planck_agent`](https://hex.pm/packages/planck_agent),
and [`planck_headless`](https://hex.pm/packages/planck_headless) are each published to Hex as
standalone libraries. You can use them independently to build your own harness, or start
from Planck's agent harness and extend it via the sidecar.

In the next post, we package Planck into a self-contained Docker bundle and ship a sidecar
with it: memory management, context compaction, credential handling, and hooks.

> As small as meaningful. As focused as necessary. As local as possible.
