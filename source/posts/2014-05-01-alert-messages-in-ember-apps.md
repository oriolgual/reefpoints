---
layout: post
title: "Alert messages in Ember Apps"
comments: true
author: 'Brian Cardarella'
github: bcardarella
twitter: bcardarella
social: true
summary: The wonder of Woof!
published: true
tags: ember
---

Something that feels missing from Ember is a way to send, from anywhere
in my app, a general alert message. Something that would pop up in my
app, display for a few seconds and disappear.

Clearly, this is something that should not be part of Ember itself but it
is a common enough feature that someone should build it.

I call it `Woof`.

<iframe width="620" height="465"
src="//www.youtube.com/embed/8wfG8ngFvPk" frameborder="0"
allowfullscreen></iframe> 

It currently only exists on [jsbin](http://jsbin.com)

<iframe class="jsbin-embed" src="http://jsbin.com/luhoquxi/7/embed?output"></iframe>

So for the time being you'll need to copy/paste. We'll be extracting it
into a plugin soon enough.

Basically, Woof will inject itself into your routes, controllers, and
components. You will need to embed the Woof component somewhere in your
templates:

```handlebars
{{x-woof}}
```

Woof injects a `woof` object similar to how `ember-data` injects a
`store` object. You can push a message onto Woof using some of the
pre-defined types or create your own:

```javascript
this.woof.info('This is an info message');
this.woof.pushObject({type: 'customType', message: 'Woof! Woof!
Woof!'});
```

This code comes with Twitter Bootstrap types setup:

* *danger*
* *info*
* *success*
* *warning*

The `x-woof` component will loop through all woofs in the array and
print out a div with the type as the class for specific styling
purposes.

The code in the JSBin is setup and styled for Twitter Bootstrap.
The event handling is setup for removing the woof when the
css opacity transition completes. Browser support may vary.
