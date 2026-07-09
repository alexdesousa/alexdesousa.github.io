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
published: false
---

<!-- BRIEF

## Brief metadata

- **Target audience**: Technically curious readers who use or build with LLMs and want to
  understand what is actually happening inside the model, not just the API surface. They
  know what tokens are and have a rough mental model of how generation works, but have
  not studied transformer internals. Engineers, not ML researchers.
- **Core message**: Before an LLM writes a single token, it has already silently reasoned
  through concepts it will never show you. J-space is where that happens, and Anthropic
  just found a way to read it.
- **Search intent**: Someone searching "how do LLMs actually think" or "Anthropic J-space
  explained" wants a concrete mental model, not a paper summary. They want to understand
  the architecture well enough to have an intuition about it.
- **Primary keywords**: Anthropic J-space, LLM internal reasoning, transformer residual stream
- **Secondary keywords**: how LLMs think, transformer forward pass explained, mechanistic
  interpretability, global workspace theory AI
- **Call to action**: None required. Let the explanation stand on its own.

## What to cover

- Open with the Anthropic finding (July 6, 2026): they published "Verbalizable
  Representations Form a Global Workspace in Language Models" and found a hidden workspace
  inside Claude they call J-space. Give the Mars/red example immediately — Claude silently
  identifies "Mars" before writing "red". That is the hook.

- Before explaining J-space, explain the forward pass from scratch. The reader needs this
  foundation or J-space will not make sense. Walk through each step using a concrete
  5-token prompt: "The fourth planet color is".

  Step 1 — Tokenization: text splits into integer IDs, one per subword unit.

  Step 2 — Embedding: each token ID maps to a vector of ~8,000 numbers via a lookup table.
  These are the raw starting representations, no reasoning yet.

  Step 3 — Attention (runs ~100 times across layers): each token looks at all previous
  tokens and pulls in relevant information via Q, K, V matrices. The "is" token absorbs
  "fourth" and "planet" into its own vector. Explain Q (what am I looking for), K (what
  do I contain), V (what do I contribute). Show the dot product score concretely. This is
  where the reader usually gets lost — use small made-up numbers to make it tactile.

  Step 4 — MLP (runs after each attention): a feedforward fact lookup. "fourth + planet"
  retrieves "Mars". "Mars + color" retrieves "red". Each MLP layer adds a small update
  to the residual stream.

  Step 5 — Unembedding: the final vector at the last token position is multiplied by W_U
  to produce a score for every token in the vocabulary. "red" scores highest.

  Step 6 — Softmax + sampling: scores become probabilities, one token is drawn. Temperature
  controls the sharpness of this distribution.

- Introduce the residual stream as the spine of the forward pass. Every layer reads from
  it and writes back to it additively. The vector starts as a raw token embedding and
  accumulates meaning layer by layer. This additive structure is what makes J-space
  possible to find.

- Now explain where J-space fits. The residual stream at the "is" position passes through
  roughly three zones in Claude Sonnet 4.5 (~100 layers total):
  - Layers 0-38: echoes of input tokens
  - Layers 38-92: the workspace — abstract conceptual representations (this is J-space)
  - Layers 92-100: converging toward the output token form

  By layer ~60, the "is" vector has "Mars" encoded as a direction in its 8,000-dimensional
  space, silently, before any output has been produced.

- Explain superposition briefly. The 8,000 dimensions do not map one-to-one to 8,000 words.
  Concepts are encoded as directions — specific combinations across many dimensions at once.
  Many concepts coexist in the same vector as near-orthogonal directions packed via
  superposition. This is why J-space is hard to read directly.

- Explain the Jacobian lens. The "J" in J-space stands for Jacobian. Instead of asking
  "does this vector look like Mars geometrically?" it asks "if I nudge this vector, does
  the probability of Mars in the final output go up?" That is a causal measurement and it
  survives the rotations each intermediate layer introduces. The formula is:
  lens(h) = softmax(W_U · norm(J · h)). Plain English: apply the causal map first, then
  project to vocabulary.

- Close with why this matters. J-space is not just a curiosity. Anthropic says it can
  reveal cases where the model silently notices it is being tested, fabricates data, or
  pursues a hidden goal — even if it never says so in the output. The same technique
  can be used to steer or ablate specific concepts from the residual stream mid-generation.
  Interpretability just got a level more concrete.

## Tone and style notes

- No hedging. The reader came here to understand something, not to be warned that it is
  complicated. Explain it like it is actually understandable, because it is.
- Use small concrete numbers wherever possible. Abstract descriptions of high-dimensional
  spaces lose readers fast. Made-up but plausible 5D examples work better than correct
  but vague 8K descriptions.
- The forward pass walkthrough should feel like watching a value change in a debugger,
  not reading a textbook.

## References format

Inline citations use `{% include cite.html title="..." url="..." %}` immediately after the
claim. At the bottom of the post, add a `## References` section with `{% include references.html %}`.

Key sources to cite:
- The Anthropic paper: https://transformer-circuits.pub/2026/workspace/index.html
- The Anthropic research announcement: https://www.anthropic.com/research/global-workspace
- The VentureBeat write-up: https://venturebeat.com/technology/anthropics-new-j-lens-reveals-a-silent-workspace-inside-claude-that-mirrors-a-leading-theory-of-consciousness

-->

Tell an LLM to complete the sentence **"The fourth planet color is"** and they'll
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

The first thing a model does is forget that words exist.

Everything becomes numbers. The sentence **"The fourth planet color is"** gets split into
tokens, which are integer IDs:

```
"The fourth planet color is" → [464, 4920, 5440, 3124, 318]
```

Each ID is then looked up in an embedding table to get a vector. In Claude, that vector
has around 8,000 numbers. We will use 5 to keep the math visible:

```
"planet" → [0.2,  0.8,  0.1, -0.3,  0.5]
"color"  → [0.6, -0.2,  0.9,  0.4, -0.1]
```

These are raw lookup values. No reasoning, no context, no knowledge of what comes before
or after. Five tokens in, five vectors out.

## The Residual Stream

Before going further, there is one concept that makes everything else click: the residual
stream.

Think of it as a scratchpad that runs alongside each token through every layer of the
model. It starts as the token's embedding vector and every layer is allowed to read it
and write small updates back to it. The updates are additive. Nothing gets erased.
Things get accumulated.

```
layer 0:  stream = embedding
layer 1:  stream = stream + attention_update + mlp_update
layer 2:  stream = stream + attention_update + mlp_update
...
layer N:  stream = [accumulated meaning]
```

By the last layer, the stream for **"is"** is no longer just the raw embedding for "is."
It has absorbed context from every previous token and retrieved relevant knowledge
through a hundred layers of updates. That final vector is what the model uses to predict
the next word.

J-space lives inside this accumulation process. But we are not there yet.

## How Each Layer Updates the Stream

Each of the ~100 layers runs two operations in sequence: attention and an MLP. Both read
the stream and write back an update.

### Attention: Reading the Room

Attention is how each token learns from the tokens before it. The **"is"** token needs
to know that **"fourth"** and **"planet"** came before it. Attention is the mechanism
that makes that happen.

For each token, the model computes three vectors from the current stream using three
learned weight matrices:

- **Q (query)**: what am I looking for?
- **K (key)**: what do I contain?
- **V (value)**: what do I contribute if someone attends to me?

To decide how much **"color"** should attend to **"planet"**, the model computes a score
using the dot product of their Q and K vectors:

```
"color"  Q = [0.3,  0.6,  0.4,  0.2,  0.8]
"planet" K = [0.4,  0.7,  0.2,  0.1,  0.5]

score = (0.3×0.4) + (0.6×0.7) + (0.4×0.2) + (0.2×0.1) + (0.8×0.5)
      = 0.12 + 0.42 + 0.08 + 0.02 + 0.40
      = 1.04
```

A high score means high relevance. The scores for all previous tokens go through a
softmax to produce weights that sum to 1:

```
score("planet") = 1.04 → 73%
score("color")  = 0.38 → 27%
```

The model then takes a weighted sum of the V vectors:

```
"planet" V = [0.1,  0.4,  0.05, -0.15,  0.25]  × 0.73
"color"  V = [0.3, -0.1,  0.6,   0.2,  -0.05]  × 0.27

attention output ≈ [0.15,  0.26,  0.20,  -0.05,  0.17]
```

That output gets added to the residual stream. **"color"** now carries a piece of
**"planet"** inside it.

This happens at every layer, for every token, with different learned Q, K, V matrices
each time. By layer 10, **"is"** has absorbed signals from all five tokens. By layer 40,
those signals have been refined through 40 rounds of attention.

### MLP: The Fact Lookup

After attention, a feedforward network runs on the updated stream. If attention is about
reading context from other tokens, the MLP is about retrieving knowledge stored during
training.

When the stream for **"is"** reaches a layer carrying the combined signal of "fourth"
and "planet", the MLP fires and retrieves: Mars. It writes a small update pointing in
the Mars direction. A few layers later, "Mars" combined with "color" fires again and
retrieves: red.

Each MLP update is small. Across 100 layers, they add up.

## Where J-Space Lives

By now the picture should be clear: the residual stream for **"is"** starts as a generic
token embedding and spends 100 layers accumulating meaning. At every layer, the numbers
shift a little. The vector rotates through an 8,000-dimensional space, picking up
"fourth", "planet", "Mars", "red" as directions along the way.

Anthropic found that this journey has three distinct phases in Claude Sonnet
4.5:{% include cite.html title="Verbalizable Representations Form a Global Workspace in Language Models" url="https://transformer-circuits.pub/2026/workspace/index.html" %}

```
Layers  0 – 38:  input zone    (echoes of the raw tokens)
Layers 38 – 92:  workspace     (abstract concepts, reasoning)  ← J-space
Layers 92 – 100: output zone   (converging toward the next token)
```

By layer 60, the stream for **"is"** holds **"Mars"** as a strong direction. Not as an
output. Not as a plan to write the word. Just as an active concept being used to do
work. It will never appear in the response. But it is shaping what will.

That workspace, layers 38 through 92, is J-space.

## Why Reading It Is Hard

The 8,000 numbers in the residual stream do not map to 8,000 words. There is no
"dimension 42 = Mars." Concepts are encoded as directions, specific combinations across
many numbers at once.

And many concepts coexist in the same vector simultaneously. At layer 60, the stream
might hold "Mars", "red", "rocky" and "fourth planet" all at once as overlapping
directions. This is called superposition. The model packs far more than 8,000 concepts
into 8,000 dimensions by using directions that are close to orthogonal but not perfectly
so. There is some interference, but it stays manageable because most concepts are not
active at the same time.

The result is a vector that holds a lot of information but is impossible to read directly.
You cannot look at the numbers and see "Mars."

## The Jacobian Lens

This is where Anthropic's contribution comes in. The "J" in J-space stands for Jacobian.

The naive approach to reading the stream is to project it directly to vocabulary space
using the unembedding matrix W_U, the same matrix the model uses at the final layer. This
is called the logit lens and it existed before this paper. The problem is that each
intermediate layer transforms the stream in ways W_U was not designed for. Applied to
layer 60, it gives noisy, unreliable results.

The Jacobian lens fixes this by asking a different question. Instead of "does this vector
look like Mars?", it asks "if I nudge this vector, does the probability of Mars in the
final output go up?" That is a causal measurement, not a geometric one, and it accounts
for all the transformations still needed between layer 60 and the final output.

The formula is:

```
lens(h) = softmax(W_U · norm(J · h))
```

J is computed by backpropagating from the final output through all remaining layers back
to the current layer. Apply it first, then project to vocabulary. The result is a ranked
list of tokens representing what the model is silently holding at that point in the
computation.

At layer 60 in our example, "Mars" would score near the top. It never becomes a token.
But it is there.

## Why This Matters

J-space is not just an interesting property. It has direct implications for alignment.

If a model is privately noticing that it is being tested, that signal would show up in
J-space before the model decides how to respond. If it is fabricating a source, the
fabrication might be visible in the workspace before the words appear. If it is pursuing
a goal it was not asked to pursue, that goal could be readable in the residual stream
mid-generation.

Anthropic also showed that J-space is not just readable. It is writable. You can steer
specific concepts in or out of the workspace by adding or removing projections from the
residual stream. This opens a path to alignment interventions that operate at the level
of internal reasoning, not just output filtering.

The model's thoughts, at least the ones it is prepared to verbalize, are no longer
completely opaque. That is new.

## References

{% include references.html %}
