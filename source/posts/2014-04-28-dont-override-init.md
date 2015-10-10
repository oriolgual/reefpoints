---
layout: post
title: "Don't override init"
comments: true
author: 'Brian Cardarella'
github: bcardarella
twitter: bcardarella
social: true
summary: Use events instead
published: true
tags: ember, best practices
ember_start_version: '1.5'
---

Too frequently I see the following problem. Someone creates a new
class and overrides `init`:

```javascript
var UsersController = Ember.ArrayController.extend({
  init: function() {
    // some custom stuff
  }
})

export default UsersController;
```

`init` is a popular function to override because it is automatically run
after the object is instantiated. It is the only lifecycle hook for
`Ember.Object`, subclasses of `Ember.Object` add their own hooks to the
lifecycle but the only one that is guaranteed to be there is `init`.

The problem is with the above example
the controller is broken. I forgot to make a call to `this._super()`
which will call the original `init` from `Ember.ArrayController`. That
`init` assigns the proper value to `content`. (via `ArrayProxy`)

Instead of overriding `init` I have been writing functions that are
specific to the logic I want to kick off on object instantiation and
have that function trigger `on('init')`:

```javascript
var UsersController = Ember.ArrayController.extend({
  doSomething: function() {
    // some custom stuff
  }.on('init')
})

export default UsersController;
```

Now I don't risk messing with the original behavior of the parent class.

Calling up the `super` chain is a powerful and important feature in
Ember but too often I was forgetting to call it. Now the only time I find
myself overriding `init` is if I want to **disrupt** the default instantiating
behavior of the object.
