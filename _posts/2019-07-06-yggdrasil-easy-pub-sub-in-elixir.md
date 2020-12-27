---
layout: post
lang: en
ref: "yggdrasil-easy-pub-sub-in-elixir"
title: "Yggdrasil: Easy Pub-Sub in Elixir"
description: "An overview of Yggdrasil's capabilities."
image: tree.jpg
image_link: "https://unsplash.com/photos/XBxQZLNBM0Q"
image_author: "Todd Quackenbush"
handle: alex
---

When I started coding in Elixir (around 2016), I was working for a financial company. Our product automatically invested money in the Forex market by copying traders' actions (_market orders_) in real time. We had the following:

{% include image.html
    src = "system.png"
    alt = "Our System"
    caption = "Our System"
%}

In other words, our system:

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

## Table of Contents

{% include toc.html
   title = "Meet Yggdrasil"
   image = "chapter.png"
%}
{% include toc.html
   title = "Yggdrasil and PostgreSQL Notifications"
   image = "chapter.png"
%}
{% include toc.html
   title = "Yggdrasil and RabbitMQ Subscriptions"
   image = "chapter.png"
%}
{% include toc.html
   title = "Yggdrasil as Distributed PubSub"
   image = "chapter.png"
%}
{% include toc.html
   prefix = "In the end"
   title = "One API to Rule Them All"
   image = "chapter.png"
%}

{% include chapter.html
   number = 1 %}

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

### One API to rule them all

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
iex> :ok = Yggdrasil.publish([name: "my_channel"], "my message")
{:mailbox, "my_message"}
```

> An interesting side-effect is that now we can send messages to any process as long as they are subscribed to the right channel without needing to know the process PID or name.

{% include chapter.html
   number = 2 %}

One thing I really like about PostgreSQL is its notifications via `pg_notify`. This feature is very useful when trying to get real-time notifications for certain changes in a databases.

### PostgreSQL notifications

Creating notifications in PostgreSQL is very easy e.g. let's say we have a table for books:

```sql
-- User table creation
CREATE TABLE books (
  id SERIAL PRIMARY KEY,
  title TEXT NOT NULL UNIQUE
);
```

and we want JSON notifications in the channel `new_books` every time a new book is created in our database e.g:

```json
{
  "id": 1,
  "title": "Animal Farm"
}
```

The trigger could be implemented as follows:

```sql
-- Trigger function creation
CREATE OR REPLACE FUNCTION trigger_new_book()
  RETURNS TRIGGER AS $$
  DECLARE
    payload JSON;
  BEGIN
    payload := json_build_object(
      'id', NEW.id,
      'title', NEW.title
    );

    PERFORM pg_notify('new_books', payload::TEXT);
    RETURN NEW;
  END;
  $$ LANGUAGE plpgsql;

-- Sets the trigger function in 'books' table
CREATE TRIGGER books_notify_new_book
  BEFORE INSERT ON books
  FOR EACH ROW
  EXECUTE PROCEDURE trigger_new_book();
```

Then, the following query would trigger our JSON message in the channel `new_books`:

```sql
INSERT INTO books (title) VALUES ('Animal Farm');
```

### The Problem

Though subscribing to our database notifications can be done easily with [Postgrex](https://github.com/elixir-ecto/postgrex) library, handling the connections to the database is a bit of a hassle. We need to ensure:

- **Connection multiplexing**: avoiding over consuming database resources.
- **Fault-tolerant connections**: supporting re-connections in case of failure or disconnection.
- **Re-connection back-off time**: avoiding overloading the database on multiple re-connections.

![problem](https://media.giphy.com/media/FrLKYbLI0djKU/giphy.gif)

### The Solution

[Yggdrasil for PostgreSQL](https://github.com/gmtprime/yggdrasil_postgres) is an adapter that supports all the features mentioned above while maintaining Yggdrasil's simple API e.g:

For our example, we could subscribe to the database messages by doing the following:

```elixir
iex> Yggdrasil.subscribe(name: "new_books", adapter: :postgres, transformer: :json)
iex> flush()
{:Y_CONNECTED, %Yggdrasil.Channel{...}}
```

Running the following query:

```sql
INSERT INTO books (title) VALUES ('1984');
```

We will get the following message in IEx:

```elixir
iex> flush()
{:Y_EVENT, %Yggdrasil.Channel{...}, %{"id" => 2, "title" => "1984"}}
```

> **Note**: `Yggdrasil` comes with built-in message transformers. We've used
> `:json` transformer for this example in order to get a map from the JSON
> data.

Additionally, our subscriber could also be an `Yggdrasil` process e.g:

```elixir
defmodule Books.Subscriber do
  use Yggdrasil

  def start_link(options \\ []) do
    channel = [
      name: "new_books",
      adapter: :postgres,
      transformer: :json
    ]

    Yggdrasil.start_link(__MODULE__, [channel], options)
  end

  @impl true
  def handle_event(_channel, %{"id" => id, "title" => title}, _state) do
    ... handle event ...
    {:ok, nil}
  end
end
```

It's also possbible to use `Yggdrasil.publish/2` with PostgreSQL:

```elixir
iex> message = %{"id" => 3, "title" => "A Brave New World"}
iex> Yggdrasil.publish([name: "new_books", adapter: :postgres, transformer: :json], message)
```

![Too easy!](https://media.giphy.com/media/zcCGBRQshGdt6/giphy.gif)

{% include chapter.html
   number = 3 %}

One of the features I really like about RabbitMQ is its queue routing. Its flexibility allows you to do interesting things without much of a hassle. But before I dig deep into RabbitMQ's routing capabilities, I would like to mention some concepts.

### Connections and Channels

RabbitMQ uses not only **connections**, but virtual connections called **channels**. The idea of channels is to introduce multiplexing in a single connection. A small system could establish only one connection with RabbitMQ while opening a channel for every single execution thread e.g:

{%- include image.html
    src = "rabbitmq-connection.png"
    alt = "RabbitMQ channel multiplexing"
    caption = "A regular RabbitMQ connection"
    -%}

The rule of thumb would be to use:

- One connection per application.
- One channel per process in the application.

> **Note**: Once our connection starts to be overloaded, we can start adding more connections to our connection pool.

With a normal RabbitMQ setup, we need to deal with:

- **Connection pools**: avoiding over consuming resources.
- **Channel cleaning**: avoiding channel memory leaks when they are not closed properly.
- **Fault-tolerant connections**: supporting re-connections in case of failure or disconnection.
- **Re-connection back-off time**: avoiding overloading the database on multiple re-connections.

### Exchanges and Queues

An **exchange** is a message router. Every **queue** attached to it will be identified by a **routing key**. Typically, routing keys are words separated by dots e.g. `spain.barcelona.gracia`.

Additionally, routing keys support wildcards, for example: `spain.barcelona.*` will match messages with routing keys like `spain.barcelona.gracia` and `spain.barcelona.raval`.

It's easier to see these concepts with an image example:

{%- include image.html
    src = "rabbitmq-exchange.png"
    alt = "RabbitMQ exchange routing"
    caption = "A RabbitMQ exchange" -%}

In the previous image:

- **__Publisher X__** and **__Publisher Y__** are sending messages to **_Exchange logs_**.
- **__Subscriber A__** is subscribed to `logs.*`.
- **__Subscriber B__** is subscribed to `logs.error`.

Then:

- **__Publisher X__** message will end up in **_Queue_** `logs.info`.
- **__Publisher Y__** message will end up in **_Queue_** `logs.error`.
- **__Subscriber A__** will receive **__Publisher X__** and **__Publisher Y__**'s messages.
- **__Subscriber B__** will receive **__Publisher Y__**'s message.

![Information Overload](https://media.giphy.com/media/3o6gDSdED1B5wjC2Gc/giphy.gif)

### Handling Subscriptions in Yggdrasil

Handling RabbitMQ's complexity might be intimidating. Fortunately, [Yggdrasil for RabbitMQ](https://github.com/gmtprime/yggdrasil_rabbitmq) generalizes the complexity in order to have a simpler API.

The biggest difference with previous adapters is the channel name. Instead of being a string, it's a tuple with the exchange name and the routing key e.g:

A subscriber would connect to the exchange `amq.topic` using the routing key `logs.*` as follows:

```elixir
iex(subscriber)> Yggdrasil.subscribe(name: {"amq.topic", "logs.*"}, adapter: :rabbitmq)
iex(subscriber)> flush()
{:Y_CONNECTED, %Yggdrasil.Channel{...}}
```

> **Note**: The exchange must exist and its type should be `topic`. The exchange `amq.topic` is created by default in RabbitMQ.

Then a publisher could send a message to the exchange `amq.topic` using `logs.info` as routing key:

```elixir
iex(publisher)> Yggdrasil.publish([name: {"amq.topic", "logs.info"}, adapter: :rabbitmq], "Some message")
:ok
```

Finally, the subscriber would receive the message:

```elixir
iex(subscriber)> flush()
{:Y_EVENT, %Yggdrasil.Channel{...}, "Some message"}
```

Additionally, the subscriber can be written using the `Yggdrasil` behaviour:

```elixir
defmodule Logs.Subscriber do
  use Yggdrasil

  def start_link(options \\ []) do
    channel = [
      name: {"amq.topic", "logs.*"},
      adapter: :rabbitmq
    ]

    Yggdrasil.start_link(__MODULE__, [channel], options)
  end

  @impl true
  def handle_event(_channel, message, _state) do
    ... handle event ...
    {:ok, nil}
  end
end
```

### Lost Messages

Yggdrasil will acknowledge the messages as soon as they arrive to the adapter, then it will broadcast them to all the subscribers. If the adapter is alive while the subscribers are restarting/failing, some messages might be lost.

Though it's possible to overcome this problem with exclusive queues, this feature is not implemented yet.

![Penguin's queueing](https://media.giphy.com/media/5YuhLwDgrgtRVwI7OY/giphy.gif)

{% include chapter.html
   number = 4 %}

Yggdrasil's default adapter supports multi-node subscriptions out-of-the-box thanks to [Phoenix PubSub](https://github.com/phoenixframework/phoenix_pubsub). This distributed capabilities can be extended to any adapter compatible with Yggdrasil v5.0 without writing a single line of extra code.

![Spock is interested!](https://media.giphy.com/media/Qtpdtlk9rpb8PKK0ih/giphy.gif)

## Before We Start

I've used {% include utils/example_link.html text = "this example project" path = "matrix" %} for the code in this article. You can skip this section safely as long as you remember the following:

- `Basic` project has only Yggdrasil.
- `Rabbit` project has Yggdrasil for RabbitMQ.
- A RabbitMQ server is available.
- The host name is called `matrix`. Your machine's will be different.

If you want to follow along with the examples in this article, you can download the example project using the following command:

{% include utils/example_download.html path = "matrix" %}

In the folder you'll find:

- {% include utils/example_link.html text = "Basic project" path = "matrix/basic" %}
  that has a basic version of [Yggdrasil](https://github.com/gmtprime/yggdrasil).
- {% include utils/example_link.html text = "Rabbit project" path = "matrix/rabbit" %}
  that has [Yggdrasil for RabbitMQ](https://github.com/gmtprime/yggdrasil_rabbitmq).
- A docker compose with a RabbitMQ server:

   ```bash
   $ cd rabbit && docker-compose up
   ```

![Make it so](https://media.giphy.com/media/bKnEnd65zqxfq/giphy.gif)

## Basic Message Distribution

Yggdrasil's default adapter piggybacks on Phoenix PubSub for the message delivery, inheriting its distributed capabilities e.g. let's say we have the following:

- The node `:neo@matrix` using `Basic` project:

   ```bash
   $ iex --sname neo -S mix
   ```

- The node `:smith@matrix` also using `Basic` project:

   ```bash
   $ iex --sname smith -S mix
   ```

- Both nodes are interconnected:

   ```elixir
   iex(smith@matrix)1> Node.connect(:neo@matrix)
   true
   ```

Then `:smith@matrix` can subscribe to any channel where `:neo@matrix` is publishing messages e.g:

In `:smith@matrix`, we subscribe to the channel `"private"`:

```elixir
iex(smith@matrix)2> Yggdrasil.subscribe(name: "private")
:ok
iex(smith@matrix)3> flush()
{:Y_CONNECTED, %Yggdrasil.Channel{...}}
:ok
```

In `:neo@matrix`, we publish a message in the channel `"private"`:

```elixir
iex(neo@matrix)1> channel = [name: "private"]
iex(neo@matrix)2> Yggdrasil.publish(channel, "What's the Matrix?")
:ok
```

Finally, we can flush `:smith@matrix` mailbox and find our message:

```elixir
iex(smith@matrix)4> flush()
{:Y_EVENT, %Yggdrasil.Channel{...}, "What's the Matrix?"}
:ok
```

Distributed pubsub as simple as that.

![Easy](https://media.giphy.com/media/dWy2WwcB3wvX8QA1Iu/giphy.gif)

## Bridged Message Distribution

The bridge adapter makes a _bridge_ between any Yggdrasil adapter and the default adapter. This allows adapters to inherit the distributed capabilities of the default adapter e.g. let's say we have the following:

- The node `:neo@matrix` using `Basic` project:

   ```bash
   $ iex --sname neo -S mix
   ```

- The node `:trinity@matrix` using `Rabbit` project:

   ```bash
   $ iex --sname trinity -S mix
   ```

- The node `:trinity@matrix` has access to a RabbitMQ server.
- Both nodes are interconnected:

   ```elixir
   iex(trinity@matrix)1> Node.connect(:neo@matrix)
   true
   ```

So our final infrastructure would look like the following:

{%- include image.html
    src = "bridge-adapter-example.png"
    alt = "A node using a bridge adapter to connect to RabbitMQ"
    caption = "A node using a bridge adapter to connect to RabbitMQ"
    -%}

Now that our nodes are connected, every adapter is available to them.

Through `:trinity@matrix`, the node `:neo@matrix` can now subscribe to
a RabbitMQ exchange:

```elixir
iex(neo@matrix)1> channel = [name: {"amq.topic", "private"}, adapter: :rabbitmq]
iex(neo@matrix)2> Yggdrasil.subscribe(channel)
:ok
iex(neo@matrix)3> flush()
{:Y_CONNECTED, %Yggdrasil.Channel{...}}
:ok
```

Or even publish messages:

```elixir
iex(neo@matrix)4> Yggdrasil.publish(channel, "What's the Matrix?")
:ok
iex(neo@matrix)3> flush()
{:Y_EVENT, %Yggdrasil.Channel{...}, "What's the Matrix?"}
:ok
```

The good thing about this feature is that it works with any adapter that supports Yggdrasil v5.0.

![The future is now!](https://media.giphy.com/media/1zRd5ZNo0s6kLPifL1/giphy.gif)

{% include chapter.html
   number = 5 %}

[Yggdrasil](https://github.com/gmtprime/yggdrasil) hides the complexity of a pub/sub and let's you focus in what really matters: **messages**.

Hope you found this article useful. Happy coding!

![Heck yeah!](https://media.giphy.com/media/26xBENWdka2DSvvag/giphy.gif)
