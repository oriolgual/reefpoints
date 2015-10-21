---
layout: post
title: "Ember Best Practices: Using Native Select Elements"
twitter: AaronMSikes
github: AaronSikes
author: 'Aaron Sikes'
tags: ember, best practices
social: true
published: true
ember_start_version: "1.13"
---

This is the third in a [series of posts][ember-best-practices] designed
to share our experiences around developing Ember.js apps and the best
practices that we've found while doing so. Check out Lin's post on
[page objects and acceptance tests][page-objects], or Estelle's post on
[not leaking state into factories][dont-leak-state].


Closure actions
---------------

Ember 1.13 came with the release of [improved actions][improved-actions].
A side effect of this feature is that it enables us to move away from
`{{view 'select'}}` and simply use DOM `<select>` elements with actions.

<blockquote class="twitter-tweet" lang="en"><p lang="en" dir="ltr">trouble with forms/form elements in ember?&#10;&#10;Turn out in 1.13.3 you can just use &quot;THE DOM&quot;&#10;&#10;<a href="http://t.co/9U73q0KOOE">http://t.co/9U73q0KOOE</a></p>&mdash; Stefan Penner (@stefanpenner) <a href="https://twitter.com/stefanpenner/status/618530886162579456">July 7, 2015</a></blockquote> <script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

His linked JSBin links to Ember canary and no longer works, but a clone
modified to use 1.13 is available [here][jsbin].

You are probably familiar with the previous action bubbling semantics.
Actions in a component are isolated within that component. Actions
outside a component bubble first through the current controller, then
through the route hierarchy.

The new approach of closure actions is simply to wrap this action up in
a function and pass it around. Anyone can call this function later. And
since the context is wrapped up in the function closure, the caller does
not need to know where it came from.

For us, the important thing is that it enables us to bind actions
directly to elements, like this: `<select onchange={{action "doThing"}}>`.

What's wrong with `{{view 'select'}}`?
--------------------------------------

Ember is moving away from two of the core concepts used by `{{view
'select'}}`.

### Views

The Ember team, as well as many people in the community building
Ember apps have discovered that the confusion around view scopes
has been a huge source of hassle and bugs. The explicit scoping of
components is much more maintainable. Thus, the Views section has been
removed from the Ember guides, and the `{{view}}` helper has been
[deprecated][ember-view-helper]. Nowadays, you get one view to go with
your route, and otherwise `View` serves simply as a superclass to
`Component`. As we move towards routable components, even the routes'
views will begin to disappear.

### Two-way data binding
Ember and the Ember ecosystem are also moving away from two-way bindings,
and towards a Data Down, Actions Up architecture (DDAU).

Triggering an action includes context that is missing with simple data
binding. *Why* is this value changing? Did we receive an update from
the back-end, or did the user hit save? Lacking this context can lead
to complicated conditional logic. Or, when combined with observers can
cause [an infinite loop hitting your back end][tip-jar-context].

It's also hard to go back once you opt-in to two-way bindings. You've
hooked up a form field with data binding, and now you realize you need
validation on that field. Oh, you also need a confirmation when it is
valid (this is some high-stakes data). You'll find yourself using an
observer, or splitting your `value` property into `previousValue` and
`currentValue` properties. It is easier to hook in for these kinds of
things when triggering actions instead.

There's also an issue of trust and boundaries. It turns out, ["components
want to be able to hand out data to their children without having to be
on guard for wayward mutations."][ember-2.0-bindings] Data flowing only
in one direction keeps things more predictable.

Okigetit, how do I do it?
-------------------------

Well, [Stefan's JSBin][jsbin] I spoke about above is really a better
example than I could give here. But, basically:

1. Use a DOM `<select>` tag, and use an `{{#each}}` to render option tags.
2. Bind an action to its `onchange` attribute.
3. Create an action handler to set the property value.

But what about `{{input}}`?
---------------------------

Although `{{input}}` behaves more like a component than a view, there
are similar issues around the data binding.

However, it turns out the same approach as above does not work quite as well with
`<input>` tags. Because of how HTMLBars re-renders views, any time you
type a character, your cursor will be reset to the end of the text
field. This is awful! There's a way around it, using the side effects of
[readDOMAttr()][readDOMAttr]. I won't go into it here, but Rob Jackson
has put together a small [example component][one-way-input] using this technique.


May your forms be filled, your inputs valid, and your error template
never render!

_Note: This post has been edited. It originally recommended using
`<input>` tags with actions. Because of the issues mentioned around
cursor position, it has been changed to discuss `select` instead._


[ember-best-practices]: /blog/categories/ember
[page-objects]: /blog/2015/09/25/ember-best-practices-acceptance-tests
[dont-leak-state]: /blog/2015/09/18/ember-best-practices-avoid-leaking-state-into-factories
[improved-actions]: https://github.com/emberjs/rfcs/blob/master/text/0050-improved-actions.md
[jsbin]: http://emberjs.jsbin.com/futokumufe/edit?html,js,output
[ember-view-helper]: http://emberjs.com/api/classes/Ember.Templates.helpers.html#method_view
[tip-jar-context]: https://youtu.be/7PUX27RKCq0?t=16m30s
[ember-2.0-bindings]: https://github.com/emberjs/rfcs/blob/master/text/0015-the-road-to-ember-2-0.md#one-way-bindings-by-default
[readDOMAttr]: http://emberjs.com/api/classes/Ember.View.html#method_readDOMAttr
[one-way-input]: http://ember-twiddle.com/2d7246875098d0dbb4a4
