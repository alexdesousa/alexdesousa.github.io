---
layout: post
lang: en
ref: "building-planck-specialized-teams-vs-general-agents"
title: "Building Planck #2: Specialized Teams vs General Agents"
description: "Why one AI trying to do everything produces mediocre results and how to design teams that don't."
handle: alex
image: team.jpg
image_author: "Hannah Busing"
tags: [ai, agents, teams]
series: "building-planck"
series_order: 2
mermaid: true
published: true
---

Reducing what an agent sees is a step in the right direction. But if we only have one
agent, we're always making a trade-off: give it more tools and it gets capable but
unfocused; take tools away and it can't do the job.

The real solution is to stop trying to fit the whole workflow into one context window.

## The Appeal of the General Agent

So, we build the general agent. A capable model, a broad system prompt, 30 tools. The
agent can "handle anything." It works. Sort of. For simple tasks it's fine. For anything
multi-step, the results are inconsistent. Sometimes brilliant, sometimes mediocre, often unpredictable.

We end up with an agent a mile wide and an inch deep.
The problem: [attention](/building-planck-context-is-the-real-problem#how-attention-works).

When every turn includes tool definitions and instructions that aren't relevant
to the current step, the model still reads them. Attention gets diluted and the
output degrades.

> The more an agent can do, the harder it is to do any one thing well.

## The Team Model

The alternative isn't a smarter agent. It's a smaller one. **Several of them.**

Instead of one agent that does everything, you have a small group where each member has a
narrow role. An orchestrator that reasons about the task, breaks it down, and delegates.
Workers that execute each step with minimal, focused context.

We need to deconstruct our workflows and figure out which experts each step requires.
That's how we turn our workflows into effective teams.

{% capture team_diagram %}
sequenceDiagram
    participant U as User
    participant O as Orchestrator
    participant P as Planner
    participant D as Developer
    participant R as Reviewer

    U->>O: "Add input validation to the login form"
    O->>P: Plan and execute this task
    P->>D: Implement step 1 [spec]
    D->>R: [code]
    R->>D: [feedback]
    D->>R: [revised code]
    R->>P: Step 1 done ✓
    P->>D: Implement step 2 [spec]
    D->>R: [code]
    R->>P: Step 2 done ✓
    P-->>O: Task complete
    O-->>U: Response
{% endcapture %}
{% include diagram.html
   content=team_diagram
   caption="The Planner coordinates steps. The Developer and Reviewer work directly with each other. The Orchestrator only sees the result."
%}

> **Note**: Though the example is for software development, we can create any team
> configuration we want, e.g., for content strategy, a Researcher, a Strategist, a Writer,
> and an Editor could be enough to create a content pipeline.

## Defining Roles

Each agent in a team has two things that together define its role: a **system prompt** and
a **tool list**.

**The system prompt** describes how the agent should behave, e.g., the planner's prompt describes
how to break a task into steps, the developer's describes how to write code. Each prompt is
small and focused on exactly one job.

**The tool list** is what the agent can actually do, e.g., a developer gets file access and a
shell, a reviewer gets read access, a planner might get read access and web search
capabilities, the orchestrator gets the tools to delegate work to others.

A developer without delegation tools simply cannot delegate, not because it's instructed
not to, but because the capability isn't there.

> We can't prompt our way out of a missing tool.

## The Compound Effect

Splitting work across specialized agents has two compounding effects:

- **Smaller, stable system prompts:** Each agent's prompt describes exactly one role and
  doesn't grow as we add capabilities to other agents. A stable system prompt means the
  [prefix cache](/building-planck-context-is-the-real-problem#the-prefix-cache) works.
  We pay to compute it once and reuse it across every turn.
- **Quality is higher per step:** A worker that only knows how to search is very good at
  searching. A worker that only knows how to write is very good at writing. Narrow scope
  produces better outputs, not worse.{% include cite.html title="How Many Tools Should an LLM Agent See? A Chance-Corrected Answer" url="https://arxiv.org/abs/2605.24660" %}

> Each agent doing less means the team doing more.

## Conclusion

Analyze your own workflows. Extract the experts needed for each step. Build your team of
agents.

This team-based architecture is at the core of [Planck](https://thebroken.link/planck):
specialized agents working together, each focused on exactly one job.

In the [next post](/building-planck-the-20-80-split), we look at the cost side of this
architecture: most steps in a well-designed team don't need a frontier model to execute them.

> A well-designed team gives you a system where each agent is small enough to be reliable
> and focused enough to be effective.

## References

{% include references.html %}
