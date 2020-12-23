---
layout: post
lang: en
ref: "skogsra-simplifying-your-elixir-configuration"
title: "Skogsrå: Simplifying Your Elixir Configuration"
description: "Improving Elixir configurations for small and large projects."
image: skogsra.jpg
image_link: "https://unsplash.com/photos/jFCViYFYcus"
image_author: "Lukasz Szmigiel"
handle: alex
---

Once an Elixir project is large enough, maintaining config files and configuration variables becomes a nightmare:

- Configuration variables are scattered throughout the code so it's very easy to forget a configuration setting.
- OS environment variables must be casted to the correct type as they are always strings.
- Required variables must be checked by hand.
- Setting defaults can sometimes be a bit cumbersome.
- No type safety.

![madness](https://media.giphy.com/media/S0KRynVEROiOs/giphy.gif)

Ideally though, configurations should be:

- Documented.
- Easy to find.
- Easy to read.
- Declarative.

In summary: __easy to maintain__.

## The problem

We'll elaborate using the the following example:

```elixir
config :myapp,
  hostname: System.get_env("HOSTNAME") || "localhost",
  port: String.to_integer(System.get_env("PORT") || "80")
```

The previous code is:

- Undocumented: `hostname` and `port` of what?
- Hard to read: Too many concerns in a single line.
- Hard to find: where are these `hostname` and `port` used?
- Not declarative: we're telling Elixir **_how_ to retrieve the values** instead of **_what_ are the values we want**.

Conclusion: __it's hard to maintain__.

## Writing a config module

We could mitigate some of these problems with one simple approach:

- Create a module for your configs.
- Create a function for every single configuration parameter you app has.

The following, though a bit more verbose, would be the equivalent to the previous config:

```elixir
defmodule Myapp.Config do
  @moduledoc "My app config."

  @doc "My hostname"
  def hostname do
    System.get_env("HOSTNAME") || "localhost"
  end

  @doc "My port"
  def port do
    String.to_integer(System.get_env("PORT") || "80")
  end
end
```

Unlike our original code, this one is:

- Documented: Every function has `@doc` attribute.
- Easy to find: We just need to to look for calls to functions defined in this module.

However, we still have essentially the same code we had before, which is:

- Hard to read.
- Not declarative.

There's gotta be a better way!

![almost](https://media.giphy.com/media/WTdg5GBR45X6NbxqJK/giphy.gif)

## There is a better way - Meet Skogsrå

[Skogsrå](https://hexdocs.pm/skogsra/readme.html) is a library for loading configuration variables with ease, providing:

- Variable defaults.
- Automatic type casting of values.
- Automatic docs and spec generation.
- OS environment template generation.
- Run-time reloading.
- Setting variable's values at run-time.
- Fast cached values access by using `:persistent_term` as temporal storage.
- YAML configuration provider for Elixir releases.

The previous example can be re-written as follows:

```elixir
defmodule Myapp.Config do
  @moduledoc "My app config."
  use Skogsra

  @envdoc "My hostname"
  app_env :hostname, :myapp, :hostname,
    default: "localhost",
    os_env: "HOSTNAME"

  @envdoc "My port"
  app_env :port, :myapp, :port,
    default: 80,
    os_env: "PORT"
end
```

This module will have these functions:

- `Myapp.Config.hostname/0` for retrieving the hostname.
- `Myapp.Config.port/0` for retrieving the port.

With this implementation, we end up with:

- Documented configuration variables: Via `@envdoc` module attribute.
- Easy to find: Every configuration variable will be in `Myapp.Config` module.
- Easy to read: `app_env` options are self explanatory.
- Declarative: we're telling Skogsrå _what we want_.
- **Bonus**: Type-safety (see [Strong typing](#strong-typing) section).

![dance](https://media.giphy.com/media/wAxlCmeX1ri1y/giphy.gif)

## How it works

Calling `Myapp.Config.port()` will retrieve the value for the port in the following order:

1. From the OS environment variable `$PORT`.
2. From the configuration file e.g. our test config file might look like:

    ```elixir
    # file config/test.exs
    use Mix.Config

    config :myapp,
      port: 4000
    ```

3. From the default value, if it exists (In this case, it would return the integer `80`).

The values will be casted as the default values' type unless the option `type` is provided (see [Explicit type casting](#explicit-type-casting) section).

Though Skogsrå has [many options and features](https://hexdocs.pm/skogsra/readme.html), we will just explore the ones I use the most:

- [Explicit type casting](#explicit-type-casting).
- [Defining custom types](#defining-custom-types).
- [Required variables](#required-variables).
- [Strong typing](#strong-typing).

## Explicit type casting

When the types are not `any`, `binary`, `integer`, `float`, `boolean` or `atom`, Skogsrå cannot automatically cast values solely by the default value's type. Types then need to be specified explicitly using the option `type`. The available types are:

- `:any` (default).
- `:binary`.
- `:integer`.
- `:float`.
- `:boolean`.
- `:atom`.
- `:module`: for modules loaded in the system.
- `:unsafe_module`: for modules that might or might not be loaded in the system.
- `Skogsra.Type` implementation: a `behaviour` for defining custom types.

## Defining custom types

Let's say we need to read an OS environment variable called `HISTOGRAM_BUCKETS` as a list of integers:

```bash
export HISTOGRAM_BUCKETS="1, 10, 30, 60"
```

We could then implement `Skogsra.Type` behaviour to parse the string correctly:

```elixir
defmodule Myapp.Type.IntegerList do
  use Skogsra.Type

  @impl Skogsra.Type
  def cast(value)

  def cast(value) when is_binary(value) do
    list =
      value
      |> String.split(~r/,/)
      |> Stream.map(&String.trim/1)
      |> Enum.map(String.to_integer/1)
    {:ok, list}
  end

  def cast(value) when is_list(value) do
    if Enum.all?(value, &is_integer/1), do: {:ok, value}, else: :error
  end

  def cast(_) do
    :error
  end
end
```

And finally use `Myapp.Type.IntegerList` in our Skogsrå configuration:

```elixir
defmodule Myapp.Config do
  use Skogsra

  @envdoc "Histogram buckets"
  app_env :buckets, :myapp, :histogram_buckets,
    type: Myapp.Type.IntegerList,
    os_env: "HISTOGRAM_BUCKETS"
end
```

Then it should be easy to retrieve our `buckets` from an OS environment variable:

```elixir
iex(1)> System.get_env("BUCKETS")
"1, 10, 30, 60"
iex(2)> Myapp.Config.buckets()
{:ok, [1, 10, 30, 60]}
```

or if the variable is not defined, from our application configuration:

```elixir
iex(1)> System.app_env(:myapp, :histogram_buckets)
[1, 10, 30, 60]
iex(2)> Myapp.Config.buckets()
{:ok, [1, 10, 30, 60]}
```

## Required variables

Skogsrå provides an option for making configuration variables mandatory. This is useful when there is no default value for our variable and Skogsrå it's expected to find a value in either an OS environment variable or the application configuration e.g. given the following config module:

```elixir
defmodule MyApp.Config do
  use Skogsra

  @envdoc "Server port."
  app_env :port, :myapp, :port,
    os_env: "PORT",
    required: true
end
```

The function `Myapp.Config.port()` will error if `PORT` is undefined and
the application configuration is not found:

```elixir
iex(1)> System.get_env("PORT")
nil
iex(2)> Application.get_env(:myapp, :port)
nil
iex(3)> MyApp.Config.port()
{:error, "Variable port in app myapp is undefined"}
```

## Strong typing

All the configuration variables will have the correct function `@spec` definition e.g. given the following definition:

```elixir
defmodule Myapp.Config do
  use Skogsra

  @envdoc "PostgreSQL hostname"
  app_env :db_port, :myapp, [:postgres, :port],
    default: 5432
end
```

The generated function `Myapp.Config.db_port/0` will have the following `@spec`:

```elixir
@spec db_port() :: {:ok, integer()} | {:error, binary()}
```

The type is derived from:

- The `default` value (in this case the integer `5432`)
- The `type` configuration value (see the previous [Explicit type casting](#explicit-type-casting) section).

## Conclusion

[Skogsra](https://hexdocs.pm/skogsra/readme.html) provides a simple way to handle your Elixir application configurations in a type-safe and organized way. Big projects can certainly benefit from using it.

Hope you found this article useful. Happy coding!

![coding](https://media.giphy.com/media/PiQejEf31116URju4V/giphy.gif)
