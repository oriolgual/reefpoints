---
layout: post
title: "Using bare arguments with Ember components"
comments: true
author: Dan McClain
twitter: "_danmcclain"
googleplus: 102648938707671188640
github: danmcclain
social: true
summary: "Positional parameters help you create cleaner APIs for your components"
published: true
tags: ember
ember_start_version: '1.13'
---

[`ember-cli-async-button`](https://github.com/dockyard/ember-cli-async-button)
provides you with a button that changes state
based on a promise in an action. We received a request a while back to allow
users to pass parameters to the action the `async-button` calls. We provided
the following API for doing so:

```hbs
{{async-button model action="save" default="Save" pending="Saving..."}}
```

The `async-button` calls the following `save` action:

```js
export default Ember.Component.extend({
  actions: {
    save(callback, model) {
      callback(model.save());
    }
  }
});
```

Notice that the callback function is still your first argument, but you get the
model as the second argument now. Prior to Ember 1.13, you had to create a
helper which looked through the parameters passed in, and instantiate the
component, and pass the parameters down. And you had to worry about bindings
and streams, so this was a bit complicated.

## Positional Parameters

[With the release of Ember
1.13](http://emberjs.com/blog/2015/06/12/ember-1-13-0-released.html),
components have a special property called `positionalParams`, which can be an
array of strings that would translate parameters in the component instantiation
into properties on the component.


```hbs
{{x-foo "Dan" "McClain"}}
```

```js
// x-foo component

export default Ember.Component.extend({
  positionalParams: ['firstName', 'lastName']
});

// Retrieving the values
Ember.get(this, 'firstName'); // => "Dan"
Ember.get(this, 'lastName');  // => "McClain"
```

`"Dan"` and `"McClain"` would be set as `firstName` and `lastName`,
respectively, on the component. You may ask "What if we want to have an
arbitrary number of parameters passed to our component?" Well, that's handled
for you too! If `positionalParams` is a string, instead of an array, the
parameters passed to your component will be an array set to that property.

```hbs
{{x-foo "Dan" "McClain"}}
```

```js
// x-foo component

export default Ember.Component.extend({
  positionalParams: 'nameParts'
});

// Retrieving the values
Ember.get(this, 'nameParts'); // => ["Dan", "McClain"]
```

## Cleaning up `ember-cli-async-button`

We no longer have to make a helper to clean up our API for `async-button`, and
[here is the commit where I did
so](https://github.com/dockyard/ember-cli-async-button/commit/79ce87f01e3244f0e0fa8aff9b4e76f18a5eeed8).
[I set the `positionalParams`
here](https://github.com/dockyard/ember-cli-async-button/commit/79ce87f01e3244f0e0fa8aff9b4e76f18a5eeed8#diff-d6ef0b16dc1a1a16373acd916a9f56f8R9).
[Note that I removed the helper that we had previously used to provide the same
API](https://github.com/dockyard/ember-cli-async-button/commit/79ce87f01e3244f0e0fa8aff9b4e76f18a5eeed8#diff-e5b0699b77066e62a7221d9735d743c4L1).
When you are creating a component and you want a way to pass parameters
that are not explicitly bound to properties, you can now use
`positionalParams`, and not muck around with helpers and streams just to pass
info into your component!
