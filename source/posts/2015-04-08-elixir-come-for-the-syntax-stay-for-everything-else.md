---
layout: post
title: "Elixir: Come for the syntax, stay for everything else"
comments: true
author: 'Brian Cardarella'
twitter: 'bcardarella'
social: true
published: true
tags: elixir
---

I have been programming for over 20 years now. I started with Basic,
found my way to C++, and spent two years writing Assembly (MASM). Then I
found Ruby. Ruby completely changed everything for me. I loved Ruby. I
loved Ruby for a reason that many "elite" programmers tend to dismiss:
the syntax.

You see, syntax is very important to me. Call it what you will,
bikeshedding, OCD, stupidity. I care about syntax. It matters to me, and
with Ruby I found a community that shared my thoughts.

When Go and Rust came along I was disappointed. Clearly these two
languages were superior in performance (and in many other areas) but were a syntactic step back
from Ruby. What was their reason? Clearly Ruby, and even Python, have
proven that the masses are attracted by clear and readable syntax. New
languages should take the best of what is currently available and
improve upon them. Go seems to target the C/C++ audience, whereas Rust
seems to attract JavaScript developers. So I guess this becomes a matter
of perspective and opinion.

Elixir is different. I put Elixir up there with Go and Rust as part of
the three new languages that will define the next decade of backend
software development. With Elixir I found a language that embraced
Ruby-like syntax, but also gave me much more.

The syntax is only skin deep, but this is part of allure of Elixir. It
is my foot in the door. When I first saw Elixir code I thought to myself
"OK, this is something I can wrap my head around".

I think a lot of Ruby developers will find their way to Elixir. It seems
that many were attracted to Go but I suspect when they start to explore
what the Elixir language has to offer they'll see the benefits.

But a language needs more than just a hook, there has to be a compelling
reason to stay. For me that was Functional Programming.

It seems that Functional Programming is making a come back. Every day
there is a new blog article on why you should start writing Functional
code. Let's break this down into a few points:

## 1. Scalability

This is an Erlang trait. Elixir apps will attempt to make the best use
of all the cores in your CPU as possible. Compared to Ruby this is a big
deal. We don't have to write anything special, the Erlang VM (BEAM) just
handles this for us automatically. This means we are efficiently using
our hardware. This type of approach didn't make a lot of sense a few
years ago, multi-core CPUs were expensive. Now they're cheap and Elixir
benefits.

## 2. Memory

Elixir programs are meant to be broken into many different processes.
The garbage collection strategy being used isn't revolutionary but
because we are dealing with **many** runtimes instead of just one the
impact on GC is negligible. In addition, you can picture how short-lived
processes might be the equivalent of objects in an OOP lanuage. We pass
messages into the process and get back a value. Each process manages its
own memory, if the process is short-lived enough GC is never even run
and the process is destroyed after it has completed its job. As opposed
to Ruby where everything lives in one world and if you stop using the
object it will get GC'd eventually impacting performance.

## 3. Immutability

Immutability got a bad rap when memory was expensive. Why would we write
applications in such a way so as to waste memory by having variables
whose values couldn't be mutated? Memory is now super cheap, and this is
not much of a concern. With this in mind we can evaluate immutability
within the context it was originally meant: to ensure state. When we
talk about parallel processing the state of a process becomes very
important. If we are expecting `X` to always be a specific value but we
are writing in a language where `X` can change this can lead to
problems.

## 4. Fault Tolerance

This one really impressed me when I started to dig into it. You may have
heard that Erlang was invented for telephony. How often do you get a
message from your phone company saying "we're updating our systems so
you won't get a call for a while". This is the level of uptime that is
achievable with Elixir. Hot code swapping is another very cool feature.
Think **real** Zero Downtime Deploys.

## 5. Community

This one is more personal to me. I'm attracted to technology that is not
centralized into one company. Go and Rust are very much just Google and
Mozilla technologies. Those languages will always be at the whim of
their corporate masters, wheras a language like Elixir that is not tied
to any one company feels like it has a more democratic process behind
its development. Let many companies develop use-cases and improve the
language. (I realize that Erlang falls into this category, but Erlang is
pretty much set in stone at this point)

The community around Elixir also feels very much like the Ruby community
did early on. I said the same thing about the Ember.js community. I
guess I'm just chasing that Ruby dragon, trying to catch that high
again.


### Conclusion

We've been exploring Elixir heavily over the past few months. The more I
dig into the language the more I love it. We're going to bet pretty
heavily on Elixir and if you are a Ruby developer looking for a change
in pace I highly suggest you check it out. The best place to start is
with [Dave Thomas'
Book](https://pragprog.com/book/elixir/programming-elixir).
