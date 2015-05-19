---
layout: post
title: "Maintaining a session in Phoenix integration tests"
comments: true
author: Dan McClain
twitter: "_danmcclain"
googleplus: 102648938707671188640
github: danmcclain
social: true
summary: "Your server has authentication, and you want to be authenticated in your tests"
published: true
tags: elixir, phoenix, testing
---

I'm using [Phoenix](http://www.phoenixframework.org) to power the backends for a couple of Ember projects I am
writing. For those applications, I've been using OAuth2 + cookie-based sessions
to authenticate my users. When testing the authentication flow, I wanted
to make sure that I was properly retrieving my session from the cookie I
previously set.

## The hard way (pre Phoenix v0.13)

The following maintains a session across multiple requests:

```elixir
test "Creating a session with a GitHub code" do
  use_cassette "successful_sign_in" do
    response = conn(:post, "/api/v1/session", %{ "authorizationCode" => "dan", "format" => "json", "provider" => "github-oauth2" })
    |> DoorApi.Endpoint.call([])

    assert response.status == 201

    current_session_request = conn(:get,  "/api/v1/session")

    current_session_response = response.cookies
    |> Enum.reduce(current_session_request, fn ({key, value}, conn) -> put_req_cookie(conn, key, value) end)
    |> DoorApi.Endpoint.call([])

    assert current_session_response.status == 200
  end
end
```

The above code copies the cookies from the first (completed) request, and
appends them to the second request. This allows you to retrieve information
from the session returned in the first request.


## But wait! There is a better way

With the release of Phoenix v0.12, new test helpers debuted that allow for the
concept of connection recycling.  TL;DR: the new helpers create a new
connection with the details of the old, completed connection. We can update our
first example to use the new helpers:

```elixir
test "Creating a session with a GitHub code" do
  use_cassette "successful_sign_in" do
    # We call the conn function to get us an initial connection.
    # From then on, we just pass the result of the last request to the helpers
    conn = post(conn(), "/api/v1/session", %{ "authorizationCode" => "dan", "format" => "json", "provider" => "github-oauth2" })

    assert conn.status == 201

    conn = get(conn, "/api/v1/session")

    assert conn.status == 200
  end
end
```

The helpers remove the need to call our endpoint, and make the code much more concise. This is a huge improvement to testing in Phoenix.
[You can see a bit more about the helpers in the `Phoenix.ConnTest` documentation](http://hexdocs.pm/phoenix/Phoenix.ConnTest.html)
