# AyeSQL: Writing Raw SQL With Elixir

This small elixir project has two implementations of the same query:

- One with AyeSQL.
- One with Ecto.

The idea is to be able to compare different approaches to the same problem.

## Running the Databases

The provided docker compose has two postgres databases:

- [Chinook](https://github.com/lerocha/chinook-database) on port 5431.
- [Ergast Developer API](https://ergast.com/mrd/db/) on port 5432.

The first one is used for the examples in the first part of the
[article](https://thebroken.link/ayesql-writing-raw-sql-in-elixir/)
and the second one is used for comparing Ecto with AyeSQL for complex queries.

Just run the following to have access to both of them:

```bash
$ docker-compose up
```

## Running the Project

This is a normal Elixir project, so, once you've run the docker compose, just
run the project:

```elixir
$ mix deps.get
$ iex -S mix
```

Once you're in IEx, just run the following:

- Ecto implementation:

  ```elixir
  iex> F1.get_accidents(1974, 1990)
  ```

- AyeSQL implementation:

  ```elixir
  iex> F1.Query.Season.get_accidents(from: 1974, to: 1990)
  ```

## Generating a valid PostgreSQL database dump

The database offered by Ergast is a MySQL dump. As I needed a PostgreSQL
database with good data, I had to migrate it to create the file `f1db.sql`.

> **Important:** You don't need to do the following as the PostgreSQL dump is
> already created and ready to be used.

The requirements for migrating the data are the following:

- `pgloader`: For migrating the data.
- `pg_dump`: For creating the SQL dump compatible with PostgreSQL.

First start the databases:

```bash
$ docker-compose -f migrate/docker-compose.yml up
```

Then, when the databases have started, migrate the data:

```bash
$ pgloader mysql://root:toor@localhost/f1db pgsql://postgres:postgres@localhost/f1db
```

And finally create the PostgreSQL valid dump.

```bash
$ PGHOST="localhot" \
  PGUSER="postgres" \
  PGPASSWORD="postgres" \
  PGDATABASE="f1db" \
  pg_dump -f f1db.sql
```
