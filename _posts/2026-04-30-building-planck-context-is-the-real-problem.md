---
layout: post
lang: en
ref: "building-planck-context-is-the-real-problem"
title: "Building Planck #1: Context Is the Real Problem with AI Agents"
description: "Why giving your AI agent more context usually makes it worse and what to do instead."
image: books.jpg
image_link: "https://unsplash.com/photos/open-book-lot-Oaqk7qqNh_c"
image_author: "Patrick Tomasso"
handle: alex
tags: [ai, agents, llm]
series: "building-planck"
series_order: 1
mermaid: true
published: false
---

Your agent is underperforming. You swapped from your local models to your favorite AI
cloud provider models and back, added more instructions, added more skills, added more
tools. The results are inconsistent: sometimes brilliant, sometimes mediocre.

You're starting to think you need a better model. Every new model release generates an
incredible FOMO, but, behind all the excitement, there's one hopeful thought:

> "This one will fix my workflow!"

After burning millions of tokens, things have improved, but your workflow is not
quite there yet. It's not fixed. It's more expensive though.

If that resonates with you, **you have a context problem.**

We need to fix a mental model that holds back most people: almost every quality
problem in AI agents traces back to poor context decisions, not model capability.

## What Context Actually Is

When we're _"chatting"_ with our agent, we're not really chatting with it. We're
actually sending an HTTP request to a server. Every single HTTP request includes
everything that's in the current chat session. Yes, everything. Every single turn.

The model has no persistent memory between calls. What it knows comes entirely from
what we include in that payload right now. That payload is our **context window**.
It contains four things:

- **System prompt**: Instructions defining the agent's role, behavior, and rules.
- **Tool definitions**: Descriptions of every tool the agent can call, including
  their parameters and what they return.
- **Conversation history**: Every prior user message and assistant response in the
  current session.
- **Injected knowledge**: Search results, file contents, retrieved memories and skills.
  Anything that was included dynamically.

{% capture context_window %}
flowchart LR
    subgraph CW["Context Window"]
        direction TB
        SP["System Prompt"]
        TD["Tool Definitions"]
        CH["Conversation History"]
        IK["Injected Knowledge"]
    end
    CW -->|"API call"| LLM[("LLM Provider")]
{% endcapture %}
{% include diagram.html
   content=context_window
   caption="Every turn sends the full context window to the provider (cloud or local)."
%}

And though some models support big context windows, that doesn't mean we can afford
to fill them: not only because of the monetary cost, but also because every token included
is a token the model must attend to.

## How Attention Works

When we say the model **"attends to"** every token, what does that actually mean?

For each token, the model computes a score between every pair of tokens in the context.
These scores determine how much each token should influence the next one generated.

If the model is completing **"Caracas is the capital of"**, it attends
more strongly to **"capital"** and **"Caracas"** than to **"is"** and **"the"**. The
scores reflect relevance.

That scoring happens across every pair. A 1,000-token context means 1,000,000 pairs
to score. Double the context to 2,000 tokens and you have 4,000,000 pairs. Four times
the computation for twice the tokens.

> **Attention is quadratic in context length.**

{% capture attention_diagram %}
xychart-beta
    x-axis ["1k", "2k", "4k", "8k", "16k", "32k"]
    y-axis "Attention pairs (M)" 0 --> 1100
    line [1, 4, 16, 64, 256, 1024]
{% endcapture %}
{% include diagram.html
   content=attention_diagram
   caption="Doubling context length quadruples the number of attention pairs the model must score."
%}

There is a second consequence beyond cost: **relevance degrades**. The model doesn't
skip tokens that aren't relevant. They're there and they affect the quality of
the result.

If half the context is boilerplate instructions that don't apply to this specific task,
those tokens still compete with the ones that do.

> It costs us more money and it compromises quality.

All those token scores are computed and stored in the **KV-cache**:

{% capture kv_cache_diagram %}
flowchart LR
    T["The"]
    Q["quick"]
    B["brown"]
    F["fox"]

    F -->|"k=0.71, v=0.56"| B
    F -->|"k=0.45, v=0.32"| Q
    F -->|"k=0.23, v=0.87"| T
    B -->|"k=0.45, v=0.32"| Q
    B -->|"k=0.23, v=0.87"| T
    Q -->|"k=0.23, v=0.87"| T
{% endcapture %}
{% include diagram.html
   content=kv_cache_diagram
   caption="Each arrow carries the cached key (k) and value (v) of the target token. Notice that \"The\" is looked up three times. Its stored pair is reused without recomputation each time."
%}

When `fox` is generated, it attends to the key-value pairs of every token before it. The
pairs are the **KV-cache**.

> Double the context length, quadruple the KV-cache memory.

**GPU memory has become one of the most contested resources on the planet.** The main DRAM
producers are now shifting their capacity to serve the AI industry. This has created a
RAM shortage where memory prices have roughly tripled by late 2025.{% include cite.html title="RAM Shortage 2025: How AI Demand is Raising DRAM Prices" url="https://intuitionlabs.ai/articles/ram-shortage-2025-ai-demand" %}{% include cite.html title="AI Boom Fuels DRAM Shortage and Price Surge" url="https://spectrum.ieee.org/dram-shortage" %}

For AI cloud providers, KV-cache memory is one of their largest costs: each chat
exponentially grows its memory usage as it progresses. It's also what drives them to
invest heavily in compression and caching strategies.

## Do You Feel _Model X_ Is Getting Dumber?

It's not your imagination. And it's probably not the model.

When a context grows very long, AI cloud providers can no longer fit the full KV-cache in
memory at standard precision. To compensate, they use compressed context representations.

Many open-source context compression techniques exist, and AI cloud providers are almost
certainly running proprietary variants optimized for their infrastructure.

Usually compression will lead to lossy memory. If it's done aggressively, the model's
output could degrade. If this happens, it will seem a bit dumber and forgetful than before.
The model is the same though.

This is not a fringe edge case. It's the operational reality of running agents at
scale, and it's why context discipline matters even when you're not worried about
cost.

> An agent that runs long sessions without managing its context doesn't just
> get expensive. It gets unreliable.

## The Prefix Cache

Not all tokens are equally expensive.

When you send an API request, the provider computes attention over every token in
your context. That's expensive.

However, providers cache the KV-cache of each request for a limited time. If the
beginning of your next request is identical to a previous request (everything is the
same except the last message), the provider will use the cached KV-cache of your previous
request and only compute the KV-cache pairs for the new tokens. This is the **prefix cache**.

As long as the cached prefix hasn't expired, you pay to compute it exactly once, then
reuse it across every subsequent turn for a fraction of the cost.

> **Note**: For local models, the prefix cache also exists. In this case, the payment is
> waiting for computing the KV-cache of the whole conversation before actually outputting
> the response of your last message. This also happens for AI cloud providers, but
> their hardware is faster. Still, it's expensive to calculate.

{% capture prefix_cache_diagram %}
flowchart TD
    A["New message"] --> B{"Conversation history matches?"}
    B -->|Yes| C["✅ Cache hit"]
    B -->|No| D["❌ Cache invalidated"]
    D --> E["Recompute KV-cache for all the context"]
    C --> F["Recompute KV-cache for the last tokens"]
{% endcapture %}
{% include diagram.html
   content=prefix_cache_diagram
   caption="A matching conversation prefix is a cache hit. Only the new tokens need to be computed."
%}

So, two rules apply:
- Use a reasonable prefix cache expiration time.
- Don't dynamically inject information in your system prompt for an active conversation e.g.
  adding `Current date: <date>`.

> Keep static instructions in the system prompt. Put dynamic state in the conversation messages.

## The Generalist Trap

A broad system prompt feels productive. You cover every case. You add 30 tools.
The agent can "do anything." Then it does everything... average.

The problem is [attention](#how-attention-works). When the context is packed with instructions and
tool definitions that aren't relevant to the current task, the model still reads them.

A specialist agent with a 100-token system prompt and 2 relevant tools
consistently outperforms a generalist with a 100,000-token system prompt
and 10 tools on the tasks the specialist is designed for.

Research confirms the underlying mechanism: context length alone degrades performance 13–85%, even with perfect retrieval.{% include cite.html title="Context Length Alone Hurts LLM Performance Despite Perfect Retrieval" url="https://arxiv.org/abs/2510.05381" %}

| Tool    | System prompt   | Role    |
| :------ | :-------------- | :------ |
| Claude Code | ~100K+ tokens{% include cite.html title="System prompt size grew ~70K tokens between Claude Code v2.1.89 and v2.1.96" url="https://github.com/anthropics/claude-code/issues/45188" %} | Generalist |
| Codex CLI | ~100K tokens{% include cite.html title="First message in fresh Codex session consumes ~100K input tokens" url="https://github.com/openai/codex/issues/18526" %} | Generalist |
| Antigravity | ~8–10K tokens{% include cite.html title="Antigravity Fast Prompt (published system prompt)" url="https://github.com/x1xhlol/system-prompts-and-models-of-ai-tools/blob/main/Google/Antigravity/Fast%20Prompt.txt" %} | Generalist |
| Pi agent | <1K tokens{% include cite.html title="What I learned building an opinionated and minimal coding agent" url="https://mariozechner.at/posts/2025-11-30-pi-coding-agent/" %} | Specialist harness |
| [Planck](https://thebroken.link/planck) orchestrator | ~1K tokens | Specialist harness |
| [Planck](https://thebroken.link/planck) worker | ~100–300 tokens | Specialist harness |

This is not a prompt trick. It's an architectural decision. The right response
to **"this agent isn't good enough"** is almost never **"add more instructions."**
It's usually **"reduce what it sees."**

> Smaller scope, tighter system prompt, fewer tools.

This is why [Planck](https://thebroken.link/planck) is built around specialized agent
teams rather than a single generalist.

## Conclusion

In this post, I shamelessly introduced [Planck](https://thebroken.link/planck):
a coding harness (and agent libraries) I created to learn more
about agents and experiment with them.

Every post in this series documents the architectural decisions
behind [Planck](https://thebroken.link/planck). Almost every single one of
them is either directly about reducing unnecessary context or about
putting the right context in front of the right model at the right time.

Even if you don't use [Planck](https://thebroken.link/planck) in the future,
I hope this helps you reason about your current workflow and how you
can make it better.

In the [next post](/building-planck-specialized-teams-vs-general-agents), we take this
further: reducing context is only the first step. The real solution is to stop trying to
fit the whole workflow into one agent.

> The model wasn't the problem. It never was.

## References

{% include references.html %}
