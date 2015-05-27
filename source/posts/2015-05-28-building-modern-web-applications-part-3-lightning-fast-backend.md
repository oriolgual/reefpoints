---
layout: post
title: "Building Modern Web Applications: Part 4 Lightning Fast Backends"
comments: true
author: 'Brian Cardarella'
twitter: 'bcardarella'
social: true
published: true
shallow: true
tags: business, technology
---

In Part 3 you learned about Single Page Applications (SPA). In order to feed
these new web applications with data our backend needs to play a
different role than it traditionally has in the past. This is where
lighting fast response times really matter as you'll be writing real API
servers.

There are many choices in this field, and many services that could
possibly meet your needs. In our experience building clinet applications
we have gravitated towards several primary concerns when it comes to
building backend APIs:

Scalability & Fault Tolerance

## Scalability

With our SPAs running entirely in our user's browser the only thing that
can slow down the experience is fetching data from the server. The more
data you fetch, the slower the response. The more users you have, the
more strain is put on the server. This is where scalability comes in.
How easy it is to scale your backend is a good question to ask yourself.
In many cases whatever technology you choose will have solutions to this
problem. It usually involves delegtaing much of the task to other
services running, caching data, and using specific strategies and tricks
to get the response times you desire. But what if there was a technology
choice you could make that allowed you to scale up very quickly and
cheaply? More omn that in a moment.

## Fault Tolerance

Errors happen. It's software, they're unavoidable. Even the best
technology teams produce buggy code that will eventually crash the
entire system. This is where fault tolerance comes in. Does your backend
have a strategy for detecting a crash and automatically recovering? If
you are running a large distributed backend across the globe does your
system know how to handle the outage of a single node? Again, like
scalaiblity whatever technology choice you make will likely have a
solution. And again, like scalability, it will usually involve a complex
system of external services to monitor and support your app. But, what
if there was a better way?

## The Better Way

At DockYard we started as a Ruby on Rails consultancy. I personally have
been building Rails applications for over a decade, working on some of
the largest scale Rails applications in the world. I saw first-hand many
of the challenge that technologies like Ruby on Rails are faced with.
When DockYard adopted Ember as how we build our SPAs Rails was holding
our applications back from being as fast as they could be. Thankfully a
new technology, from an older technology, has emerged.

Elixir is a Functional Programming language that acutally leverages
Erlang. If you are unfamiliar with Erlang, I don't blame you but you
have likely benefit from it for over thirty years. Erlang is the
technology that powers many of the world's telecom networks. The same
networks that enable billions of phone calls each day. When was the last
time you got a notice from your phone company letting you know that the
phone network was going down for an upgrade? That's right, never. That's
thanks to Erlang. What's App recently sold to Facebook for $22B (as in
Billion), was able to handle millions of communications
**simultaneously**, and do all of this with just a hand full of
engineers. All thanks to Erlang.

Ok, so Erlang is great. Why not Erlang?

In my opinion Erlang is a difficult language to approach. When
considering technology you should also consider how easy will it be to
hire engineers to support these technology decisions. Erlang is not well
known in this regard. This is where Elixir comes in.

Elixir is the best of both worlds between Erlang and Ruby. Elixir brings
in a Ruby-like syntax and compiles to Erlang. We get the scaliability
and fault tolerance traits of Ergland and get all of the developer
experience of using Ruby. Its a huge win-win.

Even better, there is a Rails-like framework called Phoenix that is
built using Elixir. We have dropped Rails developers into a Phoenix
project with *zero* Elxir experience and they have a good chance of
knowing what is happening. That is a big advantage.

So how fast is Phoenix compared to Rails? Typical well-tuned Rails
applicaitons we are seeing < 100ms response times. This is good. A
highly optimized app may see < 10ms response times. In Phoenix response
times aren't measured in **ms** they're measures in **μs**. Response
times < 1ms are very typical with Elixir. These are the type of response
times necessary to really facilitate the type of experiences we want to
build with SPAs.

If you'd like to talk with us about building applicaitons with Elixir
and Phoenix please get in touch. We're happy to help.
