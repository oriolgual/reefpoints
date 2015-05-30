---
layout: post
title: "Building Modern Web Applications: Part 2 Single Page Applications"
comments: true
author: 'Brian Cardarella'
twitter: 'bcardarella'
social: true
published: true
shallow: true
tags: business, technology
---

A new web technology that has come about in the past two years are
*Single Page Applications*. In my opinion they are a major game changer
in how modern web applications should be built. However, there are many
choices on how to build a single page app, almost too many chioces.

In this part of our multi-part series on Modern Web Applications we'll
discuss single page applications and how they compare to more
traditionally built applications. Then we'll go over the leading
technologies available today to build single page applicaitons.

## Front-end **and** Back-end

Right away, one of the first decision you will have to make is if you
will build a *server rendered application* (SRA) or a *single page
application* (SPA). Allow me to break down the difference:

### SRAs

SRAs are more traditionally built web applications. All rendering occurs
on the server and is then sent to the client. To really simplify this
picture: every time you click on a link within your application a
request is sent to the server, the server renders everything, then sends
the final result to the client.

In our opinion this model is antiquated. In the modern web application
world a new pattern has emerged and has proven to be a significant
improvement over the SRA model: the Single Page Application.

### SPAs

If SRAs render everything on the server, SPAs render everything on the
client. The best way to visualize this is to consider a native
application you may download to your iPhone. Everytime you click around
that app it doesn't request a new view from some remote server. This
allows the application to have the "native-like" feel. It is fast and
very responsive to the user. When data is required, *only* that data is
fetched from the server. This has the added benefit of freeing resources
up on your server as all of the application rendering work is now in the
hands of the client (web browser). You can think of this as distributing
the work of rendering to your users. This doesn't impact them as
rendering one application instance is negligible, and your server is
freed up from having to render our thousands (millions?) of responses
per second.

If you'd like to see a live-demo comparison of the two I've created two
comparable applications. In this demo you'll see a SRA that is being
rendered next to a SPA. You can click around the two applications. Take
note of which one *feels* faster.

## Technology Choice

So you've bought into SPAs as the best way to build your product, let's go
over the technologies available to help your team:

* Backbone
* Angular
* React
* Ember

Right away I will admit I have a favorite (Ember) but let's briefly
discuss each one:

### Backbone

At this point I cannot recommend Backbone as a serious technology to
build SPAs. Its unfortunate because Backbone was the first very
successful libraries that moved the industry in this direction. However,
Backbone as a library has insisted on staying as simple as possible.
Meaning that your team will be stuck having to create many of features
that you get for free from the other libraries. If your company is
managing several projects you can imagine how two teams using a library
like Backbone can quickly diverge in their methodology. This prevents
knowledge sharing between teams when applications are being built very
differently from one another.

There are some developers that actually appreciate this level of
freedom, but it is our experience at DockYard that more often than not
this leads to problems. For example, let's say your team builds out a
great Backbone application. There is turnover and a new team is brough
in to maintain it. Because there are no standards in how Backbone
applicaitons are built the new team may have to start from scratch, or
at the very least waste a lot of time trying to figure out how this
application was built.

### Angular

Angular suffers from the same problem as Backbone but to a lesser
degree. Angular brings far more structure to building SPAs as well as
the backing of Google. Depending upon how you look at this that can be a
good thing or a bad thing.

How can Google backing a product be bad? Recently the Angular team
annoucned Angular 2.0. Along with this announcement came the news that
Angular 2.0 is essentiall a complete re-write of the Angular library. To
the degree that no upgrade path between 1.x to 2.0 was being offered.
When a large corporate decides to take their library in a new direction,
even if that direction is a good decision, sometimes everyone else is
left in the dust. Why would a company start building an application in
Angular today knowing that soon they will be boxed-out of the newer
version of Angular or have to try a complete re-write?

Well Angular is a very popular library. It solved many of the pains
that Backbone was creating for teams. But Angular itself doesn't offer a
complete package for building SPAs. The library actually markets itself
as a tool for building custom frameworks. Ultimately this puts you in
the same space that Backbone does which is why we have decided not to
specialize in Angular development.

### React

React is from Facebook, unline Angular and Google, Facebook is actually
using React in many parts of its application. It is also built by
incredibly talented engineers. It is fast and modular. The community is
vibrant and as a library it is earning significant mind-share. While
React is not our speciality it should be taken seriously when deciding
upon which SPA library your team will use.

However, like Backbone and Angular, React is not a complete solution.
There are many third-party libraries that fill in the gaps but they are
not officially supported.

One really cool feature of React was the recently announced React
Native. Facebook has developed a way to compile their React web
applications into native applications for mobile. Unlike other
web-native solutions, for example Phonegap, React Native is actually
running *native* code on your mobile device. This means a native-like
experience using web technologies.

### Ember

Finally we come to Ember. I'm biased here because we have chosen Ember
as our SPA speciality, but for very good reason: Ember is the best in
class.

Unlike the previously mentioned libraries Ember is truly a
**framework**. Ember has already made many of the common decisions on
how to build SPAs for you. This frees your team up to focus on the
business problems rather than having to solve problems like *how do we
manage our URLs?*, *how do we compile all of the JavaScript assets?*, or
*how do we deploy our application?*. Ember is an opinionated framework
but these opinions are informed by years of experience. Companies using
Ember include Yahoo, LinkedIn, Netflix, Groupon, Microsoft, and Sony.

Ember's leadership team is also comprised of many companies rather than
just a single one. When changes are proposed for the framework how these
changes will impact everyone are taken into consideration.

Ember is also the only framework to come with a fully realized data
layer with Ember Data. The data-handling in Ember is so good that very
often our clients hire us to just build an Ember frontend that consumes their
existing backend. This is a huge win-win for companies that don't want
to risk the Big Rewrite. We can essentially deliver an entirely new
experience for your customers and they don't even know that the backend
is essentially the same.

We've been building Ember applications for a few years now. If you'd
like to discuss our Ember Consulting services we're very happy to chat!
