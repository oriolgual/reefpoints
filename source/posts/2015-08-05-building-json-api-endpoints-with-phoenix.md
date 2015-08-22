---
layout: post
title: "Building json-api endpoints with Phoenix"
comments: true
author: 'Brian Cardarella'
twitter: 'bcardarella'
social: true
published: true
tags: elixir, phoenix, ember
---

I'm currently building a [Phoenix](http://www.phoenixframework.org/) backend API that is being consumed by
[Ember Data
1.13](http://emberjs.com/blog/2015/06/18/ember-data-1-13-released.html) which uses [JSON API](http://jsonapi.org/). Here is how I 
hooked everything up.

## Configuration

You first need to tell Phoenix that it should accept `json-api` format.
I created a new
[`pipeline/2`](http://hexdocs.pm/phoenix/Phoenix.Router.html#pipeline/2)
for the API:

```elixir
# web/router.ex

pipeline :api do
  plug :accepts, ["json-api"]
end
```

We next need to add the corresponding MIME type:

```
# config/config.exs

config :plug, :mimes, %{
  "application/vnd.api+json" => ["json-api"]
}
```

Now we have to force Plug to recompile. To do this we have to `touch` a
file in the dependnecy. This may seem a little odd but the [documentation
recommends this](https://github.com/elixir-lang/plug/blob/0118337b990aa2109a7b9152ea1e244a37c7dd07/lib/plug/mime.ex#L5-L16).

`> touch deps/plug/mix.exs`

`> mix deps.compile plug`

I like to namespace my APIs so I created a scope and piped it through my
`api` pipeline:

```elixir
# web/router.ex

scope "api/v1", MyApp do
  pipe_through :api
end
```

I declare all of my API routes in that scope.

## Emitting

To emit json-api responses I am currently using
[ja\_serializer](https://github.com/AgilionApps/ja_serializer). The
author has indicated that some big changes are likely to better align
with Phoenix conventions but for now this is the only serializer I am
aware of. The README explains how to serialize, it is pretty simple. For
example, to serialize a collection form an `index` action:

```elixir
def index(conn, _) do
  foos = Repo.all(Foo)
  |> MyApp.FooSerializer.format(conn)

  json(conn, foos)
end
```

You may wish to use Views but I've opted not to.

The serializer itself would look like:

```
# serializers/foo_serializer.ex

defmodule MyApp.FooSerializer do
  use JaSerializer

  serialize "foo" do
    attributes [
      "name",
      "description"
    ]
  end
end 
```

You can embed relationships as well, check out the project for more
deatils.

## Consuming

Ember Data not only expects to get JSON API format but also sends JSON
API format back to the server when you are creating or updating. The
attributes keys come in hyphenated and everythig is nested under `"data" =>
"attributes"`. Here is how I made life easier for mmyself.

I first wrote a new plug that deserializes all params that are coming in
by forcing hyphenated keys to underscore format. It works recursively on
all keys and produces a new params object that is Phoenix friendly. Here
is the code:

```elixir
# web/plugs/deserialize.ex

defmodule MyApp.DeserializePlug do
  def init(options) do
    options
  end

  def call(%Plug.Conn{params: %{"format" => "json-api"}, method: "POST"}=conn, _opts) do
    result = _deserialize(conn)
  end

  def call(%Plug.Conn{params: %{"format" => "json-api"}, method: "PUT"}=conn, _opts) do
    _deserialize(conn)
  end

  def call(%Plug.Conn{params: %{"format" => "json-api"}, method: "PATCH"}=conn, _opts) do
    _deserialize(conn)
  end

  def call(conn, _opts), do: conn

  defp _deserialize(%Plug.Conn{}=conn) do
    Map.put(conn, :params, _deserialize(conn.params))
  end

  defp _deserialize(%{}=params) do
    Enum.into(params, %{}, fn({key, value}) -> { _underscore(key), _deserialize(value) } end)
  end

  defp _deserialize(value), do: value
  defp _underscore(key), do: String.replace(key, "-", "_")
end
```

I then added this custom plug to my `api` pipeline:

```elixir
# web/router.ex

pipeline :api do
  plug :accepts, ["json-api"]
  plug MyApp.DeserializePlug
end
```

Next, JSON API's schema is verbose and I didn't want to have to deal with this in my actions,
Elixir's pattern matching is perfect for this. I capture all the
attributes into `params`:

```elixir
def create(conn, %{"data" => %{"attributes" => params}, "type" => "json-api"}) do
  # create action now has
  # a "params" object with all the
  # attribute date from the client request
end
```

We can even guard the action for JSON API specific types.

## Conclusion

Getting JSON API working with Phoenix takes a few hoops to jump through, but
hopefully this helps you get up and running.
