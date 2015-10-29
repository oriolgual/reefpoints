---
layout: post
title: "Validating your Ecto Models with ValidField"
comments: true
author: Dan McClain
twitter: "_danmcclain"
googleplus: 102648938707671188640
github: danmcclain
social: true
summary: "Unit testing your changesets made easy"
published: true
tags: elixir, testing, phoenix
---

When we were working with Rails, we would unit test our validations with a
libary called [ValidAttribute][valid-attribute]. This library would allow you to
specify the attribute and a list of values then check if the values yield
errors or not. On a recent client project, I resurrected the pattern and
extracted it as a Phoenix library this weekend.

## Introducing ValidField

Let's import [ValidField][valid-field] and get right to the tests:

```elixir
defmodule App.UserTest do
  import ValidField
  use ExUnit.Case
  alias App.User

  test ".changeset - Validations" do
    with_changeset(%User{})
    |> assert_valid_field(:email, ["something@else.com"])
    |> assert_invalid_field(:email, ["", nil, "test"])
    |> assert_valid_field(:password, ["password123!"])
    |> assert_invalid_field(:password, [nil, "", "test", "nospecialcharacters1", "nonumber!"])
  end

  test ".changeset - Validations - complex changeset" do
    with_changeset(%User{}, fn (model, params) -> App.UserController.changeset(model, params, :insert))
    |> assert_valid_field(:email, ["something@else.com"])
  end
end
```

First, we use `with_changeset/1`, which takes the model struct as the sole
argument and returns a map that contains an anonymous function that yields a
changeset from `Model.changeset`. `with_changeset/1` assumes that your
changeset is defined at `Model.changeset/2`. If your changeset is defined
elsewhere or has additional arguments, you'll want to use `with_changeset/2`.
The first argument of `with_changeset/2` is still the model struct, but the
second argument is a function with an arity of 2. The first argument to the
function will be the model struct passed in, the second argument will be a map
of field values to be set in the changeset.

After we have a changeset map, we pass that as the first argument to
`assert_valid_field/3` and `assert_invalid_field/3`. Instead of returning a
boolean of whether or not the field is valid for the list of values passed in,
these functions run the assertions internally. This is done to provide useful
testing errors when running `mix test`. Assume that you inverted the third line
of the test to be the following (and didn't change your validations), the
following error will be generated:

```elixir
defmodule App.UserTest do
  import ValidField
  use ExUnit.Case
  alias App.User

  test ".changeset - Validations" do
    with_changeset(%User{})
    |> assert_valid_field(:email, ["something@else.com"])
    |> assert_valid_field(:email, ["", nil, "test"])
    # (ExUnit.AssertionError) Expected the following values to be valid for "email": nil, "", "tests"
  end
end
```


## OK, I see what you did there but why?

### Clean workflow for unit testing changesets

By grouping all the valid and invalid cases in your tests, you can
quickly understand what makes your changeset valid. It also allows you to
update your tests by just adding another value to either function call. Say you
want to stop accepting Gmail address as valid email address; you just add
`some-email@gmail.com` to your `assert_invalid_field` call for email, and
update the tests to satisfy this new requirement. We aren't worried about the
error message anymore.

### Less brittle tests

Most unit tests around changeset validations use the `error_on` function and
assert that the field and a specific error message are contained in the list of
errors provided. This is a decent starting point, but has a couple of
drawbacks. The first is that your test is tied directly to the error message,
meaning that changing a validation message requires you to update your test. A
correction to a gramatical error would cause a test failure, showing how
brittle this pattern could be. What if you support multiple languages? Since
your error messages might be different for an email that contains a space or
one that doesn't contain a valid domain, your tests will be more verbose since
the messages need to be matched individually.

With ValidField, you are testing the behavior of your changeset,
rather than the implementation of your error messages.

## Go forth and test your changeset

Making sure your changeset is properly defined is important, and ValidField
makes it much easier to unit test them. Having the list of valid and invalid
values for your field in your tests also serves a documentation of what should
be accepted for a given field as well.

[valid-attribute]: https://github.com/bcardarella/valid_attribute
[valid-field]: https://github.com/dockyard/valid_field
