---
layout: post
title: "On Testing Private Methods"
social: true
author: Michael Dupuis
twitter: "michaeldupuisjr"
summary: "A look at the implications of never testing private methods."
published: true
tags: code guidelines, engineering, testing
---

# Conventional Wisdom
Conventional object-oriented design wisdom says: do not unit test private methods. More importantly,
so do Dave Thomas and Andy Hunt ([*Pragmatic Unit
Testing*](https://pragprog.com/book/utj2/pragmatic-unit-testing-in-java-8-with-junit)):

> In general, you don't want to break any encapsulation for the sake of
> testing (or as Mom used to say, "don't expose your privates!"). Most
> of the time, you should be able to test a class by exercising its
> public methods. If there is significant functionality that is hidden
> behind private or protected access, that might be a warning sign that
> there's another class in there struggling to get out.

# API Concerns
So Hunt and Thomas say we don't want to break any encapsulation for the
sake of testing. What is this "encapsulation"? I think this definition by Martin Probst
on
[StackOverflow](http://stackoverflow.com/questions/8960918/how-encapsulation-is-different-from-abstraction-as-a-object-oriented-concept-in#answer-8960961) is pretty clear and concise:

> Encapsulation is a strategy used as part of abstraction. Encapsulation
> refers to the state of objects - objects encapsulate their state and
> hide it from the outside; outside users of the class interact with it
> through its methods, but cannot access the classes state directly. So
> the class abstracts away the implementation details related to its
> state.

And what does encapsulation get us? Well, it allows us to change the
internal workings of our class (the `private` methods), without worrying that we're going to
break outside code that relies on our class. This seems like a
worthwhile endeavor that will promote a system of objects that know
their bounds and respect each other's privacy; it sounds like a system
with roles and responsibilities for all of its objects, which can also
interact with each other in clear, concise, limited ways (which reduces
coupling and complexity).

# Testing Concerns
Again, the general consensus is that we don't test private methods, we
test public methods. The private methods are regarded as implementation
details. Or put another way, they are the means to the end. 

For example, When we call
`get_full_name` on an instance of `Person`, we don't care how the `Person` class determines an instance's full name. 
All we care about is that a full name is returned in a predictable
manner so that we can use it throughout the rest of the application. The
full name could be an attribute (`full_name`) on a persisted record; it
full name could be a method that merges two other attributes:

```ruby
class Person
  attr_accessor :first_name, :last_name

  def initialize(first_name, last_name)
    @first_name = first_name
    @last_name = last_name
  end

  def get_full_name
    _full_name
  end

  private

  def _full_name
    "#{@first_name} #{@last_name}"
  end
end
```

If were were to unit test the `Person` class, conventional wisdom holds
that we would only test the `#get_full_name` method. That way, in the
future, we could generate the first name by a different means, but objects
outside of the `Person` class would still be able to get the full name by calling
`#get_full_name` on a person instance.

This example is pretty straight-forward, and I wouldn't test
`#_full_name` given how simple it is. In
general, we are taught to unit test public methods to ensure that the
public interfaces of our objects are returning what we expect them to
return. But I'm sure not every method is tested equally. The more
complex a method is and the more logic it is handling, the more
assertions we're likely to make on it for all of our edge cases. This isn't a rule, it's just an
observation. On our hypothetical `Person` class, I'm going to test a
complex method like `#is_fit_to_be_president` (which would presumably hold a
lot of logic extracted out into private methods)
a hell of a lot more thoroughly than I'm going to test `#get_full_name`.

# The Issue
At this intersection of how we test in practice and how we *should* test lies the
fundamental problem with the rule of not testing private methods: the
complex methods of a class (which we will want to test most thoroughly)
are not likely to be the public methods of our class (the methods we are
told to test).

We have coupled the design of our API with the depth of our test
coverage. These two concerns are not related, and so when we write code,
we're pulled between a design that preserves encapsulation and one which
ensures we're testing complex logic efficiently.

The clearest manifestation of this inefficient testing comes when we
consider the gains of refactoring. The practice of taking a large method
filled with branching, conditional logic, and deconstructing it into
many, smaller functions with expressive names and tightly-honed
operations allows for more readable, maintainable code. Few would argue
otherwise. So why don't we apply the same logic when it comes to
testing? When we insist on only testing public methods, we return to the
practice of consolidating all of our logic into mega-methods; rather than
drawing on the benefits of our refactored code by writing small targeted
tests with clear points of failure, we push all of our logic – try to
account for all of the edge cases – into our public methods. Our methods no
longer read like the mega-methods found in unrefactored code, but we're
now forced to reason about them as such when we write tests.

Occassionally, these public functions are worse than inefficient,
they're misleading, as they obfuscate important logic. Consider 
a straight-forward `President` class which is initialized
with a set of attributes for defining a president instance:

```ruby
class President
  attr_accessor :assasinated, :senator, :slave_owner

  def initialize(attrs)
    @assasinated = attrs[:assasinated]
    @senator = attrs[:senator]
    @slave_owner = attrs[:slave_owner]

    @@president = self
  end

  def self.current
    @@president
  end
end
```

Our contrived program contains a `PresidentGuesser` which gets
initialized with the user's guess of who the `President` class has been
initialized with. Using the defining attributes of our presidents, the `PresidentGuesser`
returns `true` or `false`, based off of the user's guess.

```ruby
class PresidentGuesser
  attr_accessor :guess

  def initialize(guess)
    @guess = guess
  end

  def correct?
    case @guess
    when :kennedy
      _confirm_is_kennedy
    when :lincoln
      _confirm_is_lincoln
    when :washington
      _confirm_is_washington
    end
  end

  private

  def _confirm_is_kennedy
    President.current.senator && President.current.assasinated
  end

  # poor logic in this private method, as the attrs for Lincoln
  # are the same as for Kennedy
  def _confirm_is_lincoln
    President.current.assasinated && President.current.senator
  end

  def _confirm_is_washington
    President.current.slave_owner && !President.current.senator && !President.current.assasinated
  end
end
```

This is what our tests look like:

```ruby
require 'minitest/autorun'

class TestPresidentGuesser < Minitest::Test
  def setup
    @kennedy_attrs = { assasinated: true,
                       birthplace: 'MA',
                       senator: true,
                       slave_owner: false }

    @lincoln_attrs = { assasinated: true,
                       birthplace: 'IL',
                       senator: true,
                       slave_owner: false }

    @washington_attrs = { assasinated: false,
                          birthplace: 'VA',
                          senator: false,
                          slave_owner: true }
  end

  def test_that_kennedy_is_president
    President.new @kennedy_attrs
    guess = PresidentGuesser.new :kennedy
    assert guess.correct?
  end

  def test_that_kennedy_is_not_president
    President.new @lincoln_attrs
    guess = PresidentGuesser.new :kennedy
    refute guess.correct?, "expected Kennedy not to be President"
  end
end

# test_that_kennedy_is_president will pass
# test_that_kennedy_is_not_president will FAIL
```

The `test_that_kennedy_is_not_president` fails.

Even though we've
initialized the President class with Lincoln's attributes, the test
fails because our `PresidentGuesser` contains a private function with poor logic: the
conditional for determining whether Kennedy or Lincoln is president is the
same for both. This is obviously an oversight in writing these private
methods, however, it will not be caught in our test for the public
method `PresidentGuess#correct?`. Instead, the public method gives us a
false sense of security because of a false positive.

# Some Closing Thoughts
In our example, it's straight-forward to see where our
`#_confirm_is_kennedy` fails. In more complex relationships, it won't be
as intuitive where the failure point is once public methods begin
delegating out to private ones. Our options at that point are:

1. keep a hard line on not testing private methods and try to account
   for all of the edge cases that may be present when a public method
gets called
1. identify the more error-prone private methods you want to test and
   elevate them to public status just so you can test them (thereby mucking up your public
interface for the class).
1. test the more error-prone private methods with the understanding that
   you're creating technical debt for when you want to change the
implementation details of the class in the future.

This post is not a call for testing private methods. It's more of an
acknowledgment of the pros and cons of doing so. I think it's valuable
to note that Hunt and Thomas are not unequivocal when they say do not
unit test private methods; they predicate the rule with "most of the
time." Somewhere along the line, I feel like that was lost.
