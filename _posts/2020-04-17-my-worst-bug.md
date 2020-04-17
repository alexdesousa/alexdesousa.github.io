---
layout: article
title: "My Worst Bug"
image: bug.png
description: Debugging C/C++ can sometimes be a nightmare.
handle: alex
---

I was building a small plugin in C++ for an MT4 Server (ForEx trading server). The output of the project was a Windows DLL. Using the server's protocol, I managed to get JSON strings and parse them with [RapidJSON](https://rapidjson.org/). Everything ran smoothly in my virtual machine and in some development servers. Even Valgrind couldn't find memory leaks. I thought the plugin was ready for production...

**Oh boy was I so wrong!**

> **Note**: RapidJSON is an amazing library and if I need to parse JSON in C/C++ again, I would use it without hesitation.

![Fail!](https://media.giphy.com/media/EimNpKJpihLY4/giphy.gif)

## Debugging The Problem

Once I deployed the plugin, everything seemed fine... until the next day! A nasty segmentation fault killed the server. The plugin made us loose some money and I had to roll back the deploy.

After several days of testing, I realized the production server always died with the same set of data. I was able to pinpoint the error to RapidJSON. Something weird was happening when the memory was allocated, but none of the tools I was using to debug this were reporting any problems.

I was desperate, so I compiled the DLL with debug symbols and then I de-compiled it using [OllyDBG](http://www.ollydbg.de/).

I started reading the DLL assembly code ... **for a week and a half**! Reading assembly was horrible. I considered switching careers. But then I got to the instruction that failed! Eureka! I couldn't believe it! It felt good to finally understand the bug!

![Eureka!](https://media.giphy.com/media/WR2W4OIee3YBQbIbID/giphy.gif)

## The Bug!

The problem was that RapidJSON's custom allocator:

- Compressed the data in memory.
- Allocated only what it needed.

The production machine architecture:

- Allocated the memory RapidJSON asked for.
- Ignored the way RapidJSON wanted the data to be structured.

It's easier to see with an image:

{%- include image.html
    src = "memory_allocation.png"
    alt = "RapidJSON Custom Allocation Vs. What The Machine Actually Did"
    caption = "RapidJSON Custom Allocation Vs. What The Machine Actually Did"
    -%}

If RapidJSON needed to store an integer, a string and a boolean value, then it could fail randomly depending on the length of the string. e.g. given the integer `42` and the boolean `true`:

- For the string `Hey`, it would succeed:

{%- include image.html
    src = "memory_allocation_success.png"
    alt = "Memory allocation success."
    caption = "Memory allocation success."
    -%}

- For the string `Hi`, it would fail:

{%- include image.html
    src = "memory_allocation_fail.png"
    alt = "Memory allocation fail."
    caption = "Memory allocation fail."
    -%}

A debugging nightmare!

## The Solution

I just made RapidJSON use the machine's allocator instead of the custom one. Spent two weeks debugging something and changed just a single word in the code!

![I'm an idiot!](https://media.giphy.com/media/10PDlC02A1L5Cw/giphy.gif)

## Conclusion

Now I avoid C/C++ at all costs!

![Nightmare!](https://media.giphy.com/media/3o7TKCEuECLAqDYEY8/giphy.gif)

I hope whatever bug you're dealing with at the moment gets solved soon!
