---
layout: post
title: "Ember Best Practices: Don't Don't Override Init"
twitter: bcardarella
github: bcardarella
author: 'Brian Cardarella'
tags: ember, best practices
social: true
published: true
ember_start_version: "1.13"
---

The double negative in the title of this article is a jab at another
article I wrote nearly a year and a half ago: [Don't Override
Init](https://dockyard.com/blog/2014/04/28/dont-override-init). In that
article I advocated for never overriding the `init` function for your
`Ember.Object` derived classes, instead using `Ember.on` to kick off a
function call for what you'd normally put into `init`. At the time I
still believe this was a good recommendation. But times they do change,
and now that we're all happily using
[es2015](https://babeljs.io/docs/learn-es2015/) features via
[Babel](http://babeljs.io) we get access to the great 
[`spread`](https://babeljs.io/docs/learn-es2015/#default-rest-spread) operator.

Here is how we are now writing our `init` functions:

```js
export default Ember.Object.extend({
  init() {
    // our custom code
    return this._super(...arguments);
  }
});
```

This is a very clean approach. More importantly: it is more
performant. Ok, but what if you were using several `Ember.on` calls? That's
easy, just break them into functions:

Before:

```js
foo: on('init', () => {
  // ...
}),

bar: on('init', () => {
  // ...
}),

baz: on('init', () => {
  // ...
})
```

After:

```js
init() {
  this._super(...arguments);
  this.foo();
  this.bar();
  this.baz();
});
```

*Bonus* points for taking back control of execution order.

You don't always have to `return this._super(...arguments);` but in most
cases you should.

If you are using [ember-cli](http://ember-cli.com) and you using
`Ember.on` for init-like functionality you should consider this approach
instead. Do Override Init!
