---
layout: article
title: "Yggdrasil: Easy Pub-Sub in Elixir"
description: An overview of Yggdrasil capabilities
handle: alex
image: tree.png
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

## Table of Contents

{% include toc.html
   title = "Meet Yggdrasil"
   number = "I"
   image = "chapter.png"
%}
{% include toc.html
   title = "Yggdrasil and PostgreSQL Notifications"
   number = "II"
   image = "chapter.png"
%}
{% include toc.html
   title = "Yggdrasil and RabbitMQ Subscriptions"
   number = "III"
   image = "chapter.png"
%}
{% include toc.html
   chapter = "In the end"
   title = "One API to Rule Them All"
   number = "IV"
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

{%- include image.html  src = "rabbitmq-connection.png" alt = "RabbitMQ channel multiplexing" -%}

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

{%- include image.html  src = "rabbitmq-exchange.png" alt = "RabbitMQ exchange routing" -%}

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

[Yggdrasil](https://github.com/gmtprime/yggdrasil) hides the complexity of a pub/sub and let's you focus in what really matters: **messages**.

Hope you found this article useful. Happy coding!

![Heck yeah!](https://media.giphy.com/media/26xBENWdka2DSvvag/giphy.gif)
