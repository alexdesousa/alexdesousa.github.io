---
layout: article
title: "Yggdrasil: Easy Pub-Sub in Elixir"
description: An overview of Yggdrasil capabilities
handle: alex
image: yggdrasil.png
author: Alex de Sousa
---

When I started coding in Elixir (around 2016), I was working for a financial company. Our product automatically invested money in the Forex market by copying traders' actions (_market orders_) in real time. We had the following:

{%- include image.html  src = "system.png" alt = "Our System" -%}

In words, our system:

1. **Subscribed** to PostgreSQL for receiving _trader actions_.
2. **Published** to RabbitMQ for:
     - Categorizing _trader actions_.
     - And enqueuing _trader actions_ in the proper queue.
3. **Subscribed** to Redis for receiving updates on prices.
4. **Subscribed** to several RabbitMQ queues for:
     - Receiving the categorized _trader actions_.
     - And deciding whether it should open/close some _market orders_ or not.
5. Opened and closed _market orders_.

We needed to be able to communicate with three systems (PostgreSQL, RabbitMQ and Redis). However, in general, we only needed three actions:

- `subscribe/1` to a channel.
- `publish/2` a message in a channel.
- `unsubscribe/1` from a channel.

If we could generalize those three actions into an API, we could then implement three individual adapters for every system to handle the annoying stuff like disconnections, failures, resource management, protocols, etc.

![hard](https://media.giphy.com/media/aih5IZkussTiE/giphy.gif)

## Meet Yggdrasil

Handling subscriptions should be easy and, in an ideal world, we would only need to know _where_ to connect and _start receiving_ messages right away.

We shouldn't need to worry about secondary (yet relevant) things like disconnections, failures and managing resources.

![Yggdrasil](https://raw.githubusercontent.com/gmtprime/yggdrasil/master/priv/static/yggdrasil.png)

> _Yggdrasil_ is an immense mythical tree that connects the nine worlds in Norse cosmology.

[Yggdrasil](https://github.com/gmtprime/yggdrasil) was our pub-sub generalization. Using the strong foundations of Phoenix pub-sub library, we built an agnostic publisher/subscriber application that has:

- Multi node support.
- Simple API: `subscribe/1`, `unsubscribe/1` and `publish/2`.
- A `GenServer` wrapper for handling subscriber events easily.
- A basic adapter for using Elixir message distribution.
- Fault-tolerant adapters for:
  - [Redis](https://github.com/gmtprime/yggdrasil_redis).
  - [PostgreSQL](https://github.com/gmtprime/yggdrasil_postgres).
  - [RabbitMQ](https://github.com/gmtprime/yggdrasil_rabbitmq).

## One API to rule them all

Yggdrasil's API is very simple:

- A process subscribes to `"my_channel"`:

   ```elixir
   iex> :ok = Yggdrasil.subscribe(name: "my_channel")
   iex> flush()
   {:Y_CONNECTED, %Yggdrasil.Channel{...}}
   ```

- A process (in this case the same process) publishes the message `"my message"` in `"my_channel"`.

   ```elixir
   iex> :ok = Yggdrasil.publish([name: "my_channel"], "my message")
   ```

- The message should be in the mailbox of the subscriber process:

   ```elixir
   iex> flush()
   {:Y_EVENT, %Yggdrasil.Channel{...}, "my message"}
   ```

- The subscriber can unsubscribe from the channel to stop receiving messages:

   ```elixir
   iex> :ok = Yggdrasil.unsubscribe(name: "my_channel")
   iex> flush()
   {:Y_DISCONNECTED, %Yggdrasil.Channel{...}}
   ```

> `flush()` cleans the IEx process mailbox. In general, receiving Yggdrasil messages should be the same as receiving messages when the sender uses `send/2`.

![So easy!](https://media.giphy.com/media/cdGQHR4Qzefx6/giphy.gif)

### Yggdrasil behaviour

Yggdrasil provides a `behaviour` for writing subscribers easily. Following the previous example, the subscriber could be written as follows:

```elixir
defmodule Subscriber do
  use Yggdrasil

  def start_link do
    channel = [name: "my_channel"]
    Yggdrasil.start_link(__MODULE__, [channel])
  end

  @impl true
  def handle_event(_channel, message, _state) do
    IO.inspect {:mailbox, message}
    {:ok, nil}
  end
end
```

This subscriber will print the message as it receives it:

```elixir
iex> {:ok, _pid} = Subscriber.start_link()
iex> :ok = Yggdrasil.publishe([name: "my_channel"], "my message")
{:mailbox, "my_message"}
```

> An interesting side-effect is that now we can send messages to any process as long as they are subscribed to the right channel without needing to know the process PID or name.

## Conclusion

[Yggdrasil](https://github.com/gmtprime/yggdrasil) hides the complexity of a pub/sub and let's you focus in what really matters: **messages**.

Hope you found this article useful. Happy coding!

![Hell yeah!](https://media.giphy.com/media/CcF22AJSGZvX2/giphy.gif)
