---
layout: post
title: 'Detecting Ember.js Components Entering or Leaving the Viewport'
twitter: 'sugarpirate_'
github: 'poteto'
author: 'Lauren Tan'
tags: ember, addon, javascript
social: true
comments: true
published: true
ember_start_version: '1.11'
summary: "I wrote a post last year about how I made an Ember Mixin that would let Ember Components or Views know if their DOM element had entered or left the viewport. This time, I want to talk about how I improved the original Mixin to use the requestAnimationFrame API for improved performance at close to 60FPS."
---

*This concise version originally appears on [Medium in longform](https://medium.com/delightful-ui-for-ember-apps/creating-an-ember-cli-addon-detecting-ember-js-components-entering-or-leaving-the-viewport-7d95ceb4f5ed).*

I [wrote a post](https://medium.com/delightful-ui-for-ember-apps/ember-js-detecting-if-a-dom-element-is-in-the-viewport-eafcc77a6f86)
last year about how I made an Ember Mixin that would let Ember Components or
Views know if their DOM element had entered or left the viewport. If you're
unfamiliar with the [`getBoundingClientRect`](https://developer.mozilla.org/en-US/docs/Web/API/Element/getBoundingClientRect)
API or the approach in general (for determining if an element is in the
viewport), please have a read of that post first!

This time, I want to talk about how I improved the original Mixin to use the
[`requestAnimationFrame`](https://developer.mozilla.org/en-US/docs/Web/API/window/requestAnimationFrame)
API for improved performance at close to 60FPS. Because
[certain browsers](http://caniuse.com/#search=requestAnimationFrame) (mainly IE)
don't support `rAF`, we'll also setup an automatic fallback to using the Ember
run loop method I used in my previous post.

## Demo
![Featuring Brian](https://d262ilb51hltx0.cloudfront.net/max/1600/1*9WZqJfpL4daIEBJiufTolQ.png)

I made a simple [demo app](http://development.ember-in-viewport-demo.divshot.io/)
to demonstrate how you might use the Mixin. The goal for this addon was to allow
you to easily style or do something with Components/Views when they enter or
leave the viewport. For example, you could easily use this Mixin to build a
lazy loader for images, or even for triggering animations. Using this Mixin,
you won't need to use a jQuery plugin and can instead rely on a highly
performant ember-cli addon.

## Installing the addon
If you're using ember-cli and want to use the addon, you can install it with:

```shell
$ ember install ember-in-viewport
```

The source for the addon is available at [dockyard/ember-in-viewport](https://github.com/dockyard/ember-in-viewport).

## Rewriting the In Viewport Mixin
The Mixin still uses the [same method](https://medium.com/delightful-ui-for-ember-apps/ember-js-detecting-if-a-dom-element-is-in-the-viewport-eafcc77a6f86)
for determining if a DOM element is in the viewport, using
`getBoundingClientRect` and the window's `innerHeight` and `innerWidth`.

### Updating the Is In Viewport logic
The method for calculating whether or not a DOM element is in the viewport
remains mostly unchanged, except with the addition of a new `viewportTolerance`
argument.

```js
import Ember from 'ember';

const { merge } = Ember;

const defaultTolerance = {
  top    : 0,
  left   : 0,
  bottom : 0,
  right  : 0
};

export default function isInViewport(boundingClientRect={}, height=0, width=0, tolerance=defaultTolerance) {
  const { top, left, bottom, right } = boundingClientRect;
  const tolerances = merge(defaultTolerance, tolerance);
  let {
    top    : topTolerance,
    left   : leftTolerance,
    bottom : bottomTolerance,
    right  : rightTolerance
  } = tolerances;

  return (
    (top + topTolerance)       >= 0 &&
    (left + leftTolerance)     >= 0 &&
    (bottom - bottomTolerance) <= height &&
    (right - rightTolerance)   <= width
  );
}
```

With the addition of the `viewportTolerance` option, addon users can relax how
precise the check is. When set to `0`, the Mixin only considers an element
inside the viewport when it is completely visible inside of the viewport.

### Setting up the Class variables
```js
const {
  get,
  set,
  setProperties,
  computed,
  run,
  on,
  $,
} = Ember;

const {
  scheduleOnce,
  debounce,
  bind,
  next
} = run;

const { not }     = computed;
const { forEach } = Ember.EnumerableUtils;

const listeners = [
  { context: window,   event: 'scroll.scrollable' },
  { context: window,   event: 'resize.resizable' },
  { context: document, event: 'touchmove.scrollable' }
];

let rAFIDS = {};
```

If you haven't had the chance to use [ES2015 features](https://babeljs.io/docs/learn-es6/),
now's a good time to learn, since `ember-cli-babel` has been shipped with
ember-cli by default for a while now. Here, we're destructuring certain methods
from Ember, as well as setting up an array of listeners we want to register. I
also declare a mutable variable `rAFIDS` with `let` — I'll be using this object
to store the ID that's returned by `requestAnimationFrame` so that we can cancel
it later.

Something interesting to note is that these variables are actually shared by all
instances of the Mixin. This means if we stored the ID in that variable, it would
be overwritten by other instances of the Components that are being watched by
the Mixin. So instead, we'll store each ID as a key (the element ID for the
Component) inside of an object. More on that later.

### Initial state
```js
_setInitialState: on('init', function() {
  setProperties(this, {
    $viewportCachedEl   : undefined,
    viewportUseRAF      : canUseRAF(),
    viewportEntered     : false,
    viewportSpy         : false,
    viewportRefreshRate : 100,
    viewportTolerance   : {
      top    : 0,
      left   : 0,
      bottom : 0,
      right  : 0
    },
  });
})
```

We'll need to setup some initial values for our Mixin's state. We do this when
the Object the Mixin is mixed into is instantiated, by setting some properties
on `init`. This is because [Mixins extend a constructor's prototype](http://emberjs.com/api/classes/Ember.Mixin.html),
so certain properties will be shared amongst objects that implement the Mixin — 
and in our case, we want these to be unique to each instance.

Here, we're also going to make use of our utility function [`canUseRAF`](https://github.com/dockyard/ember-in-viewport/blob/0.2.1/addon/utils/can-use-raf.js)
to let the Mixin know whether to use `requestAnimationFrame` or fallback to the
Ember run loop.

### Setting up the DOM element rendered by the component
When the DOM element is inserted, we'll need to do a few things:

1. The initial check on render to see if the element is immediately in view
2. Setting up an observer to unbind listeners if we're not spying on the element
3. Calling the recursive `requestAnimationFrame` method
4. Setting up event listeners if we are spying on the element

```js
_setupElement: on('didInsertElement', function() {
  if (!canUseDOM) { return; }

  const viewportUseRAF = get(this, 'viewportUseRAF');

  this._setInitialViewport(window);
  this._addObserverIfNotSpying();
  this._setViewportEntered(window);

  if (!viewportUseRAF) {
    forEach(listeners, (listener) => {
      const { context, event } = listener;
      this._bindListeners(context, event);
    });
  }
})
```

### Checking if the DOM element is immediately in view
After the element has been rendered into the DOM, we want to immediately check
if it's visible. This calls the `_setViewportEntered` method in the
`afterRender` queue of the Ember run loop, which ensures that the DOM element
is actually already inserted and available for us.

```js
_setInitialViewport(context=null) {
  Ember.assert('You must pass a valid context to _setInitialViewport', context);

  return scheduleOnce('afterRender', this, () => {
    this._setViewportEntered(context);
  });
}
```

### Unbinding listeners after entering the viewport
It makes sense in certain use cases to stop watching the element after it has
entered the viewport *at least once*. For example, in an image lazy loader, we
only want to load the image once, after which it makes sense to clean up
listeners to reduce the load on the app. We do that with the `viewportSpy`
option.

Here, we programatically add an observer on the `viewportEntered` prop if
`viewportSpy` has been set to `false` by our addon user. The observer itself
doesn't do much — it unbinds listeners and then removes itself.

```js
_addObserverIfNotSpying() {
  const viewportSpy = get(this, 'viewportSpy');

  if (!viewportSpy) {
    this.addObserver('viewportEntered', this, this._viewportDidEnter);
  }
},

_viewportDidEnter() {
  const viewportEntered = get(this, 'viewportEntered');
  const viewportSpy     = get(this, 'viewportSpy');

  if (!viewportSpy && viewportEntered) {
    this._unbindListeners();
    this.removeObserver('viewportEntered', this, this._viewportDidEnter);
  }
}
```

### Setting up event listeners
Let's look at binding our event listeners before we take a look at
`_setViewportEntered`, the main method for the mixin. We'll be using the array
of listeners we declared earlier at the top of the file, and binding the event
to the appropriate context (`window` or `document`), like so:

```js
_bindListeners(context=null, event=null) {
  Ember.assert('You must pass a valid context to _bindListeners', context);
  Ember.assert('You must pass a valid event to _bindListeners', event);

  const elementId = get(this, 'elementId');

  Ember.warn('No elementId was found on this Object, `viewportSpy` will' +
    'not work as expected', elementId);

  $(context).on(`${event}#${elementId}`, () => {
    this._scrollHandler(context);
  });
}
```

Note that we can actually pass the Component's [`elementId`](http://emberjs.com/api/classes/Ember.View.html#property_elementId)
(the `id` attribute that is rendered into the DOM) to the event, which will
allow us to only unbind the listener for that particular element. If we didn't
do this, all listeners would have been unbound when the first DOM element enters
the viewport, which isn't what we'd want.

### Handling the event
Now, we can handle the event by debouncing the main method with the
`viewportRefreshRate` set by the addon user.

```js
_scrollHandler(context=null) {
  Ember.assert('You must pass a valid context to _scrollHandler', context);

  const viewportRefreshRate = get(this, 'viewportRefreshRate');

  debounce(this, function() {
    this._setViewportEntered(context);
  }, viewportRefreshRate);
}
```

### Unbinding listeners
When we eventually destroy the Component, we want to make sure we also cleanup
after ourselves. We'll have to remove both event listeners and the recursive
`requestAnimationFrame` call:

```js
_unbindListeners() {
  const elementId      = get(this, 'elementId');
  const viewportUseRAF = get(this, 'viewportUseRAF');

  Ember.warn('No elementId was found on this Object, `viewportSpy` will' +
    'not work as expected', elementId);

  if (viewportUseRAF) {
    next(this, () => {
      window.cancelAnimationFrame(rAFIDS[elementId]);
      rAFIDS[elementId] = null;
    });
  }

  forEach(listeners, (listener) => {
    const { context, event } = listener;
    $(context).off(`${event}#${elementId}`);
  });
}
```

```js
_teardown: on('willDestroyElement', function() {
  this._unbindListeners();
})
```

If you recall, the `requestAnimationFrame` function returns an ID that uniquely
identifies the entry in the callback list. We can pass this on to
`cancelAnimationFrame` in order to cancel the infinitely recursive call to the
main method. Because we register the Component's DOM `elementId` as a key in the
`rAFIDS` object, we can remove the specific rAF call for that single Component.
I've wrapped the cAF call in an `Ember.run.next` to avoid a race condition that
happens occasionally.

### Updating the viewportEntered property
Let's take a look at the main method responsible for setting the
`viewportEntered` property. This method does two main things:

1. Set `viewportEntered` to `true` or `false`
2. Fire off the next `requestAnimationFrame` step

```js
_setViewportEntered(context=null) {
  Ember.assert('You must pass a valid context to _setViewportEntered', context);

  const $viewportCachedEl = get(this, '$viewportCachedEl');
  const viewportUseRAF    = get(this, 'viewportUseRAF');
  const elementId         = get(this, 'elementId');
  const tolerance         = get(this, 'viewportTolerance');
  const height            = $(context) ? $(context).height() : 0;
  const width             = $(context) ? $(context).width()  : 0;

  let boundingClientRect;

  if ($viewportCachedEl) {
    boundingClientRect = $viewportCachedEl[0].getBoundingClientRect();
  } else {
    boundingClientRect = set(this, '$viewportCachedEl', this.$())[0].getBoundingClientRect();
  }

  const viewportEntered = isInViewport(boundingClientRect, height, width, tolerance);

  set(this, 'viewportEntered', viewportEntered);

  if ($viewportCachedEl && viewportUseRAF) {
    rAFIDS[elementId] = window.requestAnimationFrame(
      bind(this, this._setViewportEntered, context)
    );
  }
}
```

As a simple optimization, we can cache the selected DOM element inside the
Object as `$viewportCachedEl` so we don't have call the expensive DOM node
selector method every time. Then, we pass the Component's element properties to
the utility we defined earlier, and set the `viewportEntered` property.

If `requestAnimationFrame` is enabled, we call the method again inside of the
rAF method, after binding it to the correct context. Like
`Function.prototype.bind`, this creates a new function, that when called, has
its `this` keyword set to the correct value (along with any arguments). With
that first call after the element is inserted into the DOM, this fires off an
infinitely recursive loop that will only end when we cancel it.

Hence, we don't have to setup event listeners when rAF is enabled. And that's it
for the Mixin!
