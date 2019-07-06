---
layout: article
title: "Yggdrasil: Easy Pub-Sub in Elixir"
description: An overview of Yggdrasil capabilities
handle: alex
image: yggdrasil-easy-pub-sub-in-elixir
author: Alex de Sousa
---

When I started coding in Elixir, I was working for a financial company. Our
product automatically invested money in the Forex market by copying traders'
actions in real time. We had:

- Market prices coming from a Redis channel.
- Market action updates coming from a PostgreSQL notification channel.
- And consumed in order from several RabbitMQ queues.

We needed three different adapters, but only three possible actions for each:

- Subscribe to a channel.
- Unsubscribe from a channel
- Publish a message in a channel.

## Enter Yggdrasil

> _Yggdrasil_ is an immense mythical tree that connects the nine worlds in
> Norse cosmology.

[Yggdrasil](https://github.com/gmtprime/yggdrasil) was our pub-sub
generalization. Using the strong foundations of Phoenix pub-sub application, we
built an agnostic publisher/subscriber application that has:

- Multi node support.
- Simple API: `subscribe/1`, `unsubscribe/1` and `publish/2`.
- A `GenServer` wrapper for handling subscriber events easily.
- A basic adapter for using Elixir message distribution.
- Fault-tolerant adapters for
  [Redis](https://github.com/gmtprime/yggdrasil_redis),
  [PostgreSQL](https://github.com/gmtprime/yggdrasil_postgres) and
  [RabbitMQ](https://github.com/gmtprime/yggdrasil_rabbitmq).

## An API to Rule Them All

As I wrote before, Yggdrasil's API is very simple e.g:

- The process subscribes to `"my_channel"`:

```elixir
iex> :ok = Yggdrasil.subscribe(name: "my_channel")
iex> flush()
{:Y_CONNECTED, %Yggdrasil.Channel{...}}
```

- A process (in this case the same process) publishes the message `"my message"`
in `"my_channel"`.

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

> `flush()` cleans the IEx process mailbox. In general, receiving Yggdrasil
> messages should be the same as receiving messages when the sender uses
> `send/2`.

### Yggdrasil Behaviour

Yggdrasil provides a `behaviour` for writing subscribers easily. Following the
previous example, the subscriber could be written as follows:

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
iex> :ok = Yggdrasil.publisher([name: "my_channel"], "my message")
{:mailbox, "my_message"}
```

> An interesting side-effect is that now we can send messages to any process as
> long as they are subscribed to the right channel without needing to know the
> process PID or name.

## Conclusion

Yggdrasil hides the complexity of a pub/sub while giving you the opportunity of
focusing on the things that really matter: messages.
