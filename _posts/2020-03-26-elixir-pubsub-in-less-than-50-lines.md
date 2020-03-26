---
layout: article
title: "Elixir Pubsub In Less Than 50 Lines"
description: A small Elixir pubsub implementation using built-in module :pg2
handle: alex
image: web.png
author: Alex de Sousa
---

`:pg2` is a mostly unknown, but powerful Erlang module. It provides an API for creating process groups.

## Process Group

So, what's a process group? Well... it's a group of Erlang/Elixir processes.

Perhaps, the correct question would be, why do we care about process groups? Well, process groups are the foundation for publisher-subscribers (pubsubs for short).

## PG2

Understanding `:pg2` API and how it relates to a pubsub API will make it easier to understand: 

- Every process group is a `channel` e.g. a group called `:my_channel` is created:

   ```elixir
   iex> :pg2.create(:my_channel)
   :ok
   ```

- Every process in a group is a `subscriber` e.g. `self()` is part of `:my_channel` group:

   ```elixir
   iex> :pg2.join(:my_channel, self())
   :ok
   ```

- A `publisher` can `send/2` messages to a `channel` e.g. the publisher gets all the members of the group `:my_channel` and sends `"Some message"`:

   ```elixir
   iex> members = :pg2.get_members(:my_channel)
   :ok
   iex> for member <- members, do: send(member, "Some message")
   ```

- A `subscriber` will receive the messages in its mailbox:

   ```elixir
   iex> flush()
   "Some message"
   :ok
   ```

- A `subscriber` can unsubscribe from a `channel` e.g. `self()` leaves the group `:my_channel`:

   ```elixir
   iex> :pg2.leave(:my_channel, self())
   :ok
   ```

- A `channel` can be deleted:

   ```elixir
   iex> :pg2.delete(:my_channel)
   :ok
   ```

And that's it! That's the API. And you know what's the best thing about it? **It can work between connected nodes**. Keep reading and you'll see :)

![Message in cereal](https://media.giphy.com/media/mcueTtCHvqNPy/giphy.gif)

## Implementing a PubSub

A `PubSub` has three main functions:

- `subscribe/1` for subscribing to a `channel`:

   ```elixir
   def subscribe(channel) do
     pid = self()

     case :pg2.get_members(channel) do
       members when is_list(members) ->
         if pid in members do
           :ok                     # It's already subscribed.
         else
           :pg2.join(channel, pid) # Subscribes to channel
         end

       {:error, {:no_such_group, ^channel}} ->
         :pg2.create(channel)      # Creates channel
         :pg2.join(channel, pid)   # Subscribe to channel
     end
   end
   ```

- `unsubscribe/1` for unsubscribing from a `channel`.

   ```elixir
    def unsubscribe(channel) do
      pid = self()

      case :pg2.get_members(channel) do
        [^pid] ->
          :pg2.leave(channel, pid)   # Unsubscribes from channel
          :pg2.delete(channel)       # Deletes the channel

        members when is_list(members) ->
          if pid in members do
            :pg2.leave(channel, pid) # Unsubscribes from channel
          else
            :ok                      # It's already unsubscribed
          end

        _ ->
          :ok
      end
    end
   ```

- `publish/2` for sending a `message` to a `channel`.

   ```elixir
   def publish(channel, message) do
     case :pg2.get_members(channel) do
       [_ | _] = members ->
         for member <- members, do: send(member, message)
         :ok

       _ ->
         :ok
     end
   end
   ```

For a full implementation of `PubSub` you can check [this gist](https://gist.github.com/alexdesousa/4d592fe206cca17393affaefa4c8fd33).

I usually create a `.iex.exs` file in my `$HOME` folder and then run `iex`. You could do the same with the previous gist by doing the following:

```bash
~ $ PUBSUB="https://gist.githubusercontent.com/alexdesousa/4d592fe206cca17393affaefa4c8fd33/raw/4d84894f016bd9eef84bba647c77c62b9c9a6094/pub_sub.ex"
~ $ curl "$PUBSUB" -o .iex.exs
~ $ iex
```

![It's that easy](https://media.giphy.com/media/3o7btNa0RUYa5E7iiQ/giphy.gif)

## Distributed PubSub

For our distributed experiment we'll need two nodes. My machine is called `matrix` and both nodes will be `neo` and `trinity` respectively:

- `:neo@matrix`:

   ```bash
   alex@matrix ~ $ iex --sname neo
   iex(neo@matrix)1>
   ```

- `:trinity@matrix`:

   ```bash
   alex@matrix ~ $ iex --sname trinity
   iex(trinity@matrix)1> Node.connect(:neo@matrix) # Connects both nodes
   ```

Now `:neo@matrix` can subscribe to `:mainframe` channel:

```elixir
iex(neo@matrix)1> PubSub.subscribe(:mainframe)
:ok
```

And `:trinity@matrix` can send a message:

```elixir
iex(trinity@matrix)2> PubSub.publish(:mainframe, "Wake up, Neo...")
:ok 
```

> **Note**: Sometimes it takes a bit of time for nodes to synchronize their process groups, so you might need to `publish/2` your message twice.

Finally, `:neo@matrix` should receive the message:

```elixir
iex(neo@matrix)2> flush()
"Wake up, Neo..."
:ok
```

And that's it. A powerful pubsub in a few lines of code thanks to `:pg2`.

![Follow the white rabbit](https://media.giphy.com/media/S27iRp6ypEcnK/giphy.gif)

## Conclusion

Erlang has several built-in hidden gems like `:pg2` that make our lives easier.

![gem](https://media.giphy.com/media/PdfNwG98g6Sxq/giphy.gif)

Happy coding!
