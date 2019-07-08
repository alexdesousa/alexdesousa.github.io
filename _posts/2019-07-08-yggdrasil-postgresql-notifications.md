---
layout: article
title: "Yggdrasil: PostgreSQL Notifications"
description: "Yggdrasil adapter for handling pg_notify notifications from PostgreSQL"
handle: alex
image: yggdrasil-postgresql-notifications
author: Alex de Sousa
---

One thing I really like about PostgreSQL is its notifications via `pg_notify`.
This feature is very useful when trying to get real-time notifications for
certain changes in our databases.

## PostgreSQL Notifications

Creating notifications in PostgreSQL is very easy e.g:

Let's say we have a table for books:

```sql
-- User table creation
CREATE TABLE books (
    id SERIAL PRIMARY KEY,
    title VARCHAR(100) NOT NULL UNIQUE
  );
```

and we want JSON notifications in the channel `new_books` every time a
new book is created in our database e.g:

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
    payload TEXT;
  BEGIN
    payload := '{'
            || '"id":'     || NEW.id    || ','
            || '"title":"' || NEW.title || '"'
            || '}';

    PERFORM pg_notify('new_books', payload);
    RETURN NEW;
  END;
  $$ LANGUAGE plpgsql;

-- Sets the trigger function in 'books' table
CREATE TRIGGER books_notify_new_book
  BEFORE INSERT ON books
  FOR EACH ROW
  EXECUTE PROCEDURE trigger_new_book();
```

Then, the following query would trigger our JSON message in the channel
`new_books`:

```sql
INSERT INTO books (title) VALUES ('Animal Farm');
```

## The Problem

Though subscribing to our database notifications can be done easily with
[Postgrex](https://github.com/elixir-ecto/postgrex) library, handling the
connections to the database is a bit of a hassle. We need to ensure:

- Connection multiplexing between subscribers in order to avoid over consuming
  database resources.
- Fault-toletant connections by supporting reconnections in case of failure or
  disconnection.
- Reconnection backoff time (preferrably an exponential) for reconnectiong to
  avoid overloading the database.

## The Solution

[Yggdrasil for PostgreSQL](https://github.com/gmtprime/yggdrasil_postgres) is
an adapter that supports all the features mentioned above while maintaining
Yggdrasil's simple API e.g:

For our example, we could subcribe to the database messages by doing the
following:

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

## Conclusion

[Yggdrasil for PostgreSQL](https://github.com/gmtprime/yggdrasil_postgres)
simplifies subscriptions to PostgreSQL notifications and let's you focus in
what really matters: **messages**.
