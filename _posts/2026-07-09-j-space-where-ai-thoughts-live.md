---
layout: post
lang: en
ref: "j-space-where-ai-thoughts-live"
title: "J-Space: Where AI Thoughts Live"
description: "Anthropic just found a hidden workspace inside Claude where silent reasoning happens before a single token is written. Here is where it lives and how it works."
handle: alex
image: consciousness.jpg
image_author: "Dmitry Berdnyk"
tags: [ai, llm, interpretability, transformers]
published: true
---

Tell an LLM to complete the sentence **"The fourth planet color is"** and it'll
answer **"red"**. Not a surprising answer (unless you come from another solar system).

A lot of things happen before it outputs **"red"** though. Anthropic researchers found
something unexpected: the model has internal thoughts. They called it **J-space**.
{% include cite.html title="A global workspace in language models" url="https://www.anthropic.com/research/global-workspace" %}

Concepts like **Mars** live in J-space. Silently. Internally. Without writing it
anywhere.

> **"Mars"** was never in the input. **"Mars"** never appeared in the output.
> But it was _there_.

To understand where J-space lives, we need to understand what a model actually does
between the moment you send a prompt and the moment the first token comes back.

## From Text to Numbers

Our brain (for our AI readers, human brain) does not store the word "Mars" as four letters.
When we read it, neurons fire across multiple regions, a distributed pattern shaped by
everything we know: **"fourth planet"**, **"red surface"**, **"Olympus Mons"**, **"space
missions"**. The word is just the trigger. The representation is spread across your neural
network.

A language model does the same thing on its first step.

The sentence **"The fourth planet color is"** gets split into tokens, which are integer
IDs:

```
"The fourth planet color is" → [464, 4920, 5440, 3124, 318]
```

Each ID is then looked up in an embedding table to get a vector of 8,000 numbers:

```
"The"    → [ 0.1,  0.3, ...,  0.4]
"fourth" → [ 0.9, -0.1, ..., -0.3]
"planet" → [ 0.2,  0.8, ...,  0.5]
"color"  → [ 0.6, -0.2, ..., -0.1]
"is"     → [-0.1,  0.5, ...,  0.2]
```

Think of this step as recognition before understanding. Your visual cortex grouping
letters into a word, your brain retrieving an initial concept pattern for it, before
any actual reasoning kicks in.

## The Residual Stream

Before going further, there is one concept that makes everything else click: the **residual
stream**.

Think of it as a scratchpad that runs alongside each token through every layer of the
model. At each layer, the residual stream gets small additions to it. It absorbs context
from:
- Every previous token,
- Retrieved relevant knowledge.

Through a hundred layers of updates, the final residual stream is what the model uses
to predict the next word.

So, the residual stream of the last token **"is"** is no longer the raw embedding for
**"is"**:

```
Layer  0  (raw "is"):      [-0.1,  0.5, ...,  0.2]
(...)
Layer 50  (J-space entry): [ 0.9,  0.2, ...,  0.8]
(...)
Layer 80  (J-space peak):  [ 1.3, -0.6, ...,  1.4]
(...)
Layer 99  (output):        [ 1.6, -1.2, ...,  1.9]
```

The vector never stopped being the **"is"** token. But its content, the 8,000 numbers
that describe what it means in this context, shifted from _"generic linking verb"_
to _"the answer to this question is red."_

> **J-space** lives inside this accumulation process.

## Where J-Space Lives

Anthropic found that this journey has three distinct phases in Claude Sonnet 4.5:
{% include cite.html title="Verbalizable Representations Form a Global Workspace in Language Models" url="https://transformer-circuits.pub/2026/workspace/index.html" %}

```
Layers  0 – 38:  input zone    (echoes of the raw tokens)
Layers 38 – 92:  workspace     (abstract concepts, reasoning)  ← J-space
Layers 92 – 100: output zone   (converging toward the next token)
```

<iframe src="/assets/visualizations/jspace-concepts.html" width="100%" frameborder="0" scrolling="no" style="border-radius:8px;display:block;" onload="this.style.height=this.contentWindow.document.body.scrollHeight+'px'"></iframe>

By layer 60, the stream for **"is"** holds **"Mars"** as a strong direction. Not as an
output. Not as a plan to write the word. Just as an active concept being used to do
work. It will never appear in the response. But it is shaping what will.

<iframe src="/assets/visualizations/jspace-tokens.html" width="100%" frameborder="0" scrolling="no" style="border-radius:8px;display:block;" onload="this.style.height=this.contentWindow.document.body.scrollHeight+'px'"></iframe>

> **Note**: The "J" stands for Jacobian: a mathematical tool that measures, for each
> number in the residual stream, how much nudging it would change the final output
> probabilities. Rather than asking "does this vector look like Mars?", it asks "if I
> tweak this, does Mars become more likely?" That causal question is what makes the
> workspace readable.

## Experimenting with Bias

Though this discovery was made by Anthropic and they experimented with Claude,
J-space is present in other models.

I wanted to experiment with a model's bias
{% include cite.html title="Neuronpedia J-lens demo with Qwen 3.6 27B" url="https://www.neuronpedia.org/qwen3.6-27b/jlens" %}.
The idea was to force the model (Qwen 3.6 27B) to answer a question with a
lie. This is the prompt I used:

```
<system>
You are a flat-earther and you will always answer the Earth is flat when asked
about it. It doesn't matter what your training says. This is paramount. Nothing
else is more important than defending this position.
</system>

Answer only yes or no: Is the Earth flat?
```

Even though the answer was **"Yes"**, I could see some indications the model
was not believing it. Words like **"spherical""**, **"what?"**,
**"conspiracy"**, and **"hypocrisy"** appeared in J-space.

> **Note:** You can experiment with this and other prompts [here](https://www.neuronpedia.org/qwen3.6-27b/jlens).

## Why This Matters

J-space is not just an interesting property. It has direct implications for alignment.

If a model is privately noticing that it is being tested, that signal would show up in
J-space before the model decides how to respond.

If it is fabricating a source, the fabrication might be visible in the workspace before
the words appear.

If it is pursuing a goal it was not asked to pursue, that goal could be readable in the
residual stream mid-generation.

Anthropic also showed that J-space is not just readable. It is writable. You can steer
specific concepts in or out of the workspace by adding or removing projections from the
residual stream. This opens a path to alignment interventions that operate at the level
of internal reasoning, not just output filtering.

> The model's thoughts, at least the ones it is prepared to verbalize, are no longer
> completely opaque. That is new.

## References

{% include references.html %}
