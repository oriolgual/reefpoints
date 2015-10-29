---
layout: post
title: "How long it took to convert our team from Rails to Phoenix"
comments: true
author: Brian Cardarella
twitter: bcardarella
github: bcardarella
social: true
published: true
tags: elixir, phoenix
---

One week.

That is how long it took for our engineers, who had all (but one) worked
with [Rails][rails] for a few years, to be productive on a new [Phoenix][phoenix] client
project.

I had assigned each of them to read Part 1 of [Dave Thomas' Programming Elixir][book]
book which was only 160 pages of material. Part 1 introduces early
[Functional Programming][fp] concepts and the [Elixir][elixir] standard library. In my
mind, this is enough to make the switch.

> **“It was cool being able to contribute to a Phoenix app without prior
> experience with the framework thanks to the similarity in structure
> with Rails. Elixir is the biggest hurdle, but a quick read through the
> key concepts is enough to make you productive - not to mention
> learning a new language is fun!”**
>
> *-- Romina Vargas, DockYard Engineer*

At the higher level of writing actions, routes, tests, models, queries, etc... there is so much
overlap with the concepts that exist in Rails that it was simply a
matter of syntax that had to be learned before a Rails engineer could
make contributions back to Phoenix applications.

There is no doubt that Phoenix borrows *a lot* of concepts and structure
from Rails. For good reason, Rails nailed the [MVC app pattern][mvc]. The
benefit here is that a lot of that domain knowledge on how to build
Rails apps can be transferred over to building Phoenix
apps.

> **“Ruby on Rails had a pretty steep learning curve. Not only did I have
> to study a new programming language, I had to master the MVC framework
> as well. But with RoR under my belt, the learning curve for Elixir and
> Phoenix was significantly reduced. Plus pattern matching makes
> everything way easier!”**
>
> *-- Marin Abernethy, DockYard Engineer*

Now, don't get me wrong. I am not suggesting that after this one week
that you should be ramped up on the complexities of Elixir and the
Erlang ecosystem. I think there is enough to Erlang that could take
years to fully absorb. But that's not the point.

The best way to write a faster Rails app is to write it in
Phoenix.

[Get in touch with us if you'd like to move from Rails to Phoenix. We can
help!][cta]

[book]: https://pragprog.com/book/elixir/programming-elixir
[rails]: http://rubyonrails.org
[phoenix]: http://phoenixframework.org
[elixir]: http://elixir-lang.org
[fp]: https://en.wikipedia.org/wiki/Functional_programming
[mvc]: http://betterexplained.com/articles/intermediate-rails-understanding-models-views-and-controllers/
[cta]: https://dockyard.com/contact
