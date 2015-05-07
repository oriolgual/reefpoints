---
layout: post
title: "Announcing Voorhees"
comments: true
author: Dan McClain
twitter: "_danmcclain"
googleplus: 102648938707671188640
github: danmcclain
social: true
summary: "Voorhees is a library for testing Phoenix JSON APIs"
published: true
tags: elixir, testing, phoenix
---

I've been building JSON APIs in [Phoenix](http://www.phoenixframework.org) for
a few Ember apps I've been working on. I wanted to ensure that the JSON
response didn't include extra information in the form of attributes that
should be kept server side, and returned the correct payload. We can break
these two concerns into separate tests, the first making sure that our JSON
response conforms to a specific "schema", the other making sure that the
attributes that we care about are correct.
[Voorhees](https://github.com/danmcclain/voorhees), named after [JSON...I mean
Jason Voorhees](http://www.imdb.com/media/rm4040136960/ch0002146#), provides
functions for both of these concerns.

## `Voorhees.matches_schema?`

`Voorhees.matches_schema?(payload, expected_keys)` makes sure that a payload
conforms to a certain format. You pass in a string that is the API response and
a list of keys to check it against. If that payload has extra keys, or the
payload is missing keys, the function returns `false`, causing it to fail the
`assert` in your test.

### Examples

Validating simple objects

    iex> payload = ~S[{ "foo": 1, "bar": "baz" }]
    iex> Voorhees.matches_schema?(payload, [:foo, "bar"]) # Property names can be strings or atoms
    true

    # Extra keys
    iex> payload = ~S[{ "foo": 1, "bar": "baz", "boo": 3 }]
    iex> Voorhees.matches_schema?(payload, [:foo, "bar"])
    false

    # Missing keys
    iex> payload = ~S[{ "foo": 1 }]
    iex> Voorhees.matches_schema?(payload, [:foo, "bar"])
    false

Validating lists of objects

    iex> payload = ~S/[{ "foo": 1, "bar": "baz" },{ "foo": 2, "bar": "baz" }]/
    iex> Voorhees.matches_schema?(payload, [:foo, "bar"])
    true


Validating nested lists of objects

    iex> payload = ~S/{ "foo": 1, "bar": [{ "baz": 2 }]}/
    iex> Voorhees.matches_schema?(payload, [:foo, bar: [:baz]])
    true

Validating that a property is a list of scalar values

    iex> payload = ~S/{ "foo": 1, "bar": ["baz", 2]}/
    iex> Voorhees.matches_schema?(payload, [:foo, bar: []])
    true

## `Voorhees.matches_payload?`

`Voorhees.matches_payload?(payload, expected_payload)` makes sure that a payload
contains the right values. It should be used in conjuction with
`Voorhees.matches_schema?/2`. `Voorhees.matches_payloads?` ignores values that
are present in the `payload` but not in the `expected_payload`; this allows you
to ignore server generated values, like `id` and `created_at` timestamps. You
may not necessarily care about the values of these server generated attributes.
It will return `false` when a value in `expected_payload` is missing from the
`payload`, or when the values in the `payload` differ from the `expected_payload`.

### Examples

Expected payload keys can be either strings or atoms

    iex> payload = ~S[{ "foo": 1, "bar": "baz" }]
    iex> Voorhees.matches_payload?(payload, %{ :foo => 1, "bar" => "baz" })
    true

Extra key/value pairs in payload are ignored

    iex> payload = ~S[{ "foo": 1, "bar": "baz", "boo": 3 }]
    iex> Voorhees.matches_payload?(payload, %{ :foo => 1, "bar" => "baz" })
    true

Extra key/value pairs in expected payload cause the validation to fail

    iex> payload = ~S[{ "foo": 1, "bar": "baz"}]
    iex> Voorhees.matches_payload?(payload, %{ :foo => 1, "bar" => "baz", :boo => 3 })
    false

Validates scalar lists

    iex> payload = ~S/{ "foo": 1, "bar": ["baz"]}/
    iex> Voorhees.matches_payload?(payload, %{ :foo => 1, "bar" => ["baz"] })
    true

    # Order is respected
    iex> payload = ~S/{ "foo": 1, "bar": [1, "baz"]}/
    iex> Voorhees.matches_payload?(payload, %{ :foo => 1, "bar" => ["baz", 1] })
    false

Validates lists of objects

    iex> payload = ~S/[{ "foo": 1, "bar": { "baz": 2 }}]/
    iex> Voorhees.matches_payload?(payload, [%{ :foo => 1, "bar" => %{ "baz" => 2 } }])
    true

Validates nested objects

    iex> payload = ~S/{ "foo": 1, "bar": { "baz": 2 }}/
    iex> Voorhees.matches_payload?(payload, %{ :foo => 1, "bar" => %{ "baz" => 2 } })
    true

Validates nested lists of objects

    iex> payload = ~S/{ "foo": 1, "bar": [{ "baz": 2 }]}/
    iex> Voorhees.matches_payload?(payload, %{ :foo => 1, "bar" => [%{ "baz" => 2 }] })
    true

## Take a machete to your API responses

Make sure your API responses are what you expect, or cut them down at the knees when your tests fail!
