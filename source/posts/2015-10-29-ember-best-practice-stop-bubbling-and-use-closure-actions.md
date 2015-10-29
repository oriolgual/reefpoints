---
layout: post
title: "Ember Best Practices: Stop bubbling actions and use closure actions"
comments: true
author: Dan McClain
twitter: "_danmcclain"
googleplus: 102648938707671188640
github: danmcclain
social: true
summary: "Bubbling no longer required"
published: true
tags: ember, javascript
ember_start_version: 1.13
---

Back in January, I talked about [bubbling actions through components][bubbles]
so that you could nest components and have an action be triggered from the
depths of your inner component. This involved passing actions down through your
components, and then using `sendAction` to trigger the action at each level
until you got all the way out of your nesting. With the introduction of
[closure actions][closure], you end up passing actions down, but no longer have
to bubble out.

## Actions down

Let's look at the example from the previous blog post again:

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

Notice how we we are using the `action="buttonClick"` above the `press-button`
component to pass the action down. We end up calling `this.sendAction()` in
both components so that the button 2 levels deep calls the action defined in
the controller.

What if I told you that you only need to define the templates for the
components, and no longer need to have and actions defined within the
components themselves?

```hbs
{{! index.hbs}}
  {{pressCount}} Button presses
  {{button-wrapper click=(action "buttonClick")}}

{{! components/button-wrapper.hbs}}
  <h2>Button Wrapper</h2>
  {{press-button click=(action this.attrs.click)}}

{{! components/press-button.hbs}}
  <button {{action (action this.attrs.click}}>My Button</button>
```

Closure actions are called by using the `action` subexpression, which in turn
passes down the function to the component, defining it at `this.attrs.<property
name>`, just like other properties passed to your component. At the bottom, the
`<button>` action just calls the action, and the controller action is the same
as before. [You can see it in action here][simple-example]. There is no code
backing the component at this point.

## Ok, what if I wanted to do something a bit more complicated

This is where closure actions really show off. With closure actions, you can
have the function you pass in to the action *return a value*. This was
previously impossible because the return value of a function was used to
determine if the action should bubble. This also highlights one of the
potential gotchas you may encounter when you first start using closure actions:
they don't bubble. If you use a closure action, it won't bubble out of the
controller/component. If you need this behavior, you need to call `this.send`
in the controller to fire an action that will be triggered in your route. [Here
is an example][route-action]. Note that the name of the action sent is
different than the action called, you'll end up in an infinite loop if you try
to `this.send('buttonClick')`. When routeable components land, you'll likely
end up passing the route action into the component using closure actions, so
unless you really need route actions with closure actions, I would recommend
against leaning on this example.

## Can you do anything cool with closure actions?

Yes, you can now [curry][curry]! You can pass multiple arguments to the `action` helper
at each level. Those arguments are added to the function at each scope. Let's
look at a bit of code to make this clearer:

```hbs
{{! index}}
    Things: {{things}}
    {{cat-wrapper class="button-wrapper" click=(action "buttonClick")}}
    {{dog-wrapper class="button-wrapper" click=(action "buttonClick")}}

{{! components/cat-wrapper.hbs}}
    <h2>Cats</h2>
    {{press-button count=1 class="press-button" click=(action this.attrs.click "cat")}}
    {{press-button count=2 class="press-button" click=(action this.attrs.click "cats")}}

{{! components/dog-wrapper.hbs}}
    <h2>Dogs</h2>
    {{press-button count=1 class="press-button" click=(action this.attrs.click "dog")}}
    {{press-button count=2 class="press-button" click=(action this.attrs.click "dogs")}}

  {{! components/press-button.hbs}}
    <button {{action (action this.attrs.click this.attrs.count)}}>{{this.attrs.count}}</button>
```

Notice how we pass `cat/cats/dog/dogs` to the `action` of each `press-button`
in the `cat-wrapper` and `dog-wrapper` component, but in the `press-button`
component, we just pass the count to the `action` helper after passing it the
function we want to call. The function that is called in `press-button` has the
following signature `function(thing, count)`, so if we click the first cat
button, the `buttonClick` action in the controller is called with `'cat'` as
the first argument, and `count` as the second argument. [Here is a living
version of this example][currying-action].

## What if I don't use the action helper at in my deepest component?

All the examples so far use the `action` helper in `press-button`, but if you
wanted to call your action manually, you'd just call `this.attrs.click()` to
call the function passed into the component. [Here is an updated version of the
currying example that uses an action at in the `press-button`
component][explicit-call]. We still pass the argument to the curried function.

## Functions Down, Actions up

With the introduction of closure actions in Ember 1.13, we gained a power way
of passing data down in the form of functions to pass data up and out of our
components. This was possible before, but it was also a lot more work. You'd
have to manually bubble actions all the way out, but now we punch a hole down
to our deepest component and fire the action directly from there. This will
lead to easier debugging, as the `sendAction` way was a lot harder to grok
where your component actions were breaking.

[explicit-call]: http://jsbin.com/logawi/4/edit?html,js,output
[currying-action]: http://jsbin.com/logawi/3/edit?html,js,output
[curry]: https://en.wikipedia.org/wiki/Currying
[route-action]: http://jsbin.com/logawi/2/edit?html,js,output
[simple-example]: http://jsbin.com/logawi/1/edit?html,js,output
[closure]: http://emberjs.com/blog/2015/06/12/ember-1-13-0-released.html#toc_closure-actions
[bubbles]: https://dockyard.com/blog/2015/01/28/bubbling-actions-through-components
