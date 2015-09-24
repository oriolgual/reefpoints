---
layout: post
title: "Bubbling actions through components"
comments: true
author: Dan McClain
twitter: "_danmcclain"
googleplus: 102648938707671188640
github: danmcclain
social: true
summary: "Let your actions be handled in your controllers and routes"
published: true
tags: emberjs
---

If you're building components for re-use, you're likely to run into the
following problem. Say you built a form component, and you also built some type
of custom button component. You want the action triggered by the button to be
handled in your controller or route. If you try to bind the action of that
inner button, it will be captured by the component, not the controller. The
issue is that components swallow actions that are triggered within them; they
will not escape the component unless we punch a hole for them to bubble up.

You need to capture the action of the inner components and fire off new actions
from the parent component. In the example below, the button is in a component
that is inside of another component. The controller has an action to increment
the counter.

<iframe class="jsbin-embed" src="http://jsbin.com/suvat/4/embed?output"></iframe>

Our components' templates are super simple:

```hbs
{{! index.hbs}}
  {{pressCount}} Button presses
  {{button-wrapper action="buttonClick"}}

{{! components/button-wrapper.hbs}}
  <h2>Button Wrapper</h2>
  {{press-button action="buttonClick"}}

{{! components/press-button.hbs}}
  <button {{action "buttonClick"}}>My Button</button>
```

Notice we bind to the action of the `press-button` component in our
`button-wrapper` component, and in our `index` template, we bind to the action
of the `button-wrapper`. This alone doesn't work; we need to send actions from
each component when they receive actions from the underlying component.

In our `press-button` component, we send an action when the button is clicked:

```js
App.PressButtonComponent = Ember.Component.extend({
  classNames: 'press-button',
  actions: {
    buttonClick: function() {
      this.sendAction();
    }
  }
});
```

Our `button-wrapper` receives the action from the `press-button` component and
fires its own action:

```js
App.ButtonWrapperComponent = Ember.Component.extend({
  classNames: 'button-wrapper',
  actions: {
    buttonClick: function() {
      this.sendAction();
    }
  }
});
```

And our index controller receives that action from `button-wrapper` and
increments the `pressCount`:

```js
App.IndexController = Ember.Controller.extend({
  pressCount: 0,

  actions: {
    buttonClick: function() {
      this.incrementProperty('pressCount');
    }
  }
});
```

## Wrapping up

It's pretty easy, yet tedious to wire up an action from a component within a
component. You can trigger actions multiple levels above your initial action,
and even mutate the action's arguments on the way up. Maybe the model that
triggered the initial action should be put into some type of intermediate
state. Maybe you want to normalize several different actions that are bubbling
up through certain components. Since you need to manually bubble these
actions up, we can manipulate them at each level that the bubbling occurs. It's
somewhat trivial to handle, you just have to be aware of the work needed to
tie all your pieces together.
