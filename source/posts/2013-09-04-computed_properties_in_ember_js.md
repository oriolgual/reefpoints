---
layout: post
title: 'Computed Properties in Ember.Js'
twitter: twokul
github: twokul
author: Alex Navasardyan
googleplus: 102932077691986053176
tags: ember
social: true
published: true
comments: true
summary: 'Computed Properties magic explained'
ember_start_version: '1.0'
---

Note: Short version of this post is a part of [Ember.Js
Guides](http://emberjs.com/guides/object-model/computed-properties/).

## What Are Computed Properties?

In a nutshell, it's a property whose value is computed the first time
it's asked for. You can define the computed property as a function and
when someone asks for it, Ember will automatically invoke the function
and treat the return value like value of the property.

Here's a very well-known example:

```javascript
App.Person = Ember.Object.extend({
  firstName: null,
  lastName: null,
  fullName: function() {
    return this.get('firstName') + ' ' + this.get('lastName');
  }.property('firstName', 'lastName')
});

var ironMan = Person.create({
  firstName: "Tony",
  lastName:  "Stark"
});

ironMan.get('fullName');
// "Tony Stark"
```

The code above defines a computed property `fullName` by calling
`property()` on the function with two dependencies `firstName` and
`lastName` and whenever it gets called, it returns `firstName` + `lastName`.

## Inception

Let's take a look at another example. Say we want to add a description
computed property to `App.Person`. It will aggregate other properties like
`fullName`, `age`, `country`:

```javascript
App.Person = Ember.Object.extend({
  firstName: null,
  lastName: null,
  age: null,
  country: null,
  fullName: function() {
    return this.get('firstName') + ' ' + this.get('lastName');
  }.property('firstName', 'lastName'),
  description: function() {
    return this.get('fullName') + '; Age: ' +
           this.get('age') + '; Country: ' +
           this.get('country');
  }.property('fullName', 'age', 'country')
});

var captainAmerica = Person.create({
  fullName: 'Steve Rogers',
  age: 80,
  country: 'USA'
});

captainAmerica.get('description');
// "Steve Rogers; Age: 80; Country: USA"
```

Notice that you can use an existing computed property as a dependency for a
new one.

## Caching

By default, all computed properties are cached. That means that once you
requested the value of computed property (called `get` on it), it's going
to compute and cache its value:

```javascript
captainAmerica.get('description');
// computes the value and returns "Steve Rogers; Age: 80; Country: USA"
captainAmerica.get('description');
// returns cached "Steve Rogers; Age: 80; Country: USA"
```

A computed property gets recomputed when any of the properties it depends on change:

```javascript
captainAmerica.set('country', 'United States of America');
captainAmerica.get('description'); // computes the value and returns"Steve Rogers; Age: 80; Country: United States of America"
```

## Read Only

This property is `false` by default. You won't be able to set the value of
the computed property if you call `readOnly` on it:

```javascript
App.Person = Ember.Object.extend({
  description: function() {
    // implementation
  }.property('fullName', 'age', 'country').readOnly()
});

var captainAmerica = Person.create();
captainAmerica.set('description', 'hero');
// "Cannot Set: description on: <(unknown mixin):ember133>"
```

## Alternative syntax for defining Computed Properties

This code:

```javascript
App.Person = Ember.Object.extend({
  firstName: null,
  lastName: null,
  fullName: Ember.computed('firstName', 'lastName', function() {
    return this.get('firstName') + ' ' + this.get('lastName');
  })
});
```

does exactly the same thing as this code:

```javascript
App.Person = Ember.Object.extend({
  firstName: null,
  lastName: null,
  fullName: function() {
    return this.get('firstName') + ' ' + this.get('lastName');
  }.property('firstName', 'lastName')
});
```

with the difference that the first example works if you disable [Ember's
prototype extension](http://emberjs.com/api/#property_EXTEND_PROTOTYPES).

## How are Computed Properties different from Observers and Bindings?

The concept of `observer` is pretty simple. You have something that you want to track the change of. You add an observer to it, so next time it changes, a certain event is going to be fired notifying you that that something has changed.

There are two types of observers: `before` (observesBefore) and `after` (observes). When observer event (callback) is fired, it's called with two arguments: `obj` and `keyName`. It doesn't pass the value of the property to the event (callback). The reason is because the property you're watching might be lazily computed.

`Observers` are used by CP internally to invalidate CP's cache when its dependency keys were changed. Observers (like CPs) don't use runloop magic (fired "right away").

`Observers` are not going to fire if the value is unchanged from before (changing existing `lastName` from `Stark` to `Stark` won't trigger the observer callback).

`Bindings` is an internal concept that is not meant to be used. I'm not saying you can't, it's better not to. Typically, you don't need to use it in your application, using CP is plenty enough.

`Bindings` are meant to keep a property of two objects in sync. Their update (sync) happens through run loop, so there might be a period of time when two objects have the same property with different values and only by the end of a `sync` queue those values are going to be the same.

For example, in Ember those two objects are controller and view (any time a controller's property changes, view's property changes as well).

## What do I use and when?

**Computed properties** are good for combining other properties or doing
transformations on the property.

**Observers** are good for tracking changes of a property and reacting to
them. Observers should contain behaviour that reacts to the change.

**Bindings** are used to make sure that the properties from the different objects
are in sync. They are rarely used and most of the times can be replaced
with computed properties.

## Futher reading

You can read more about Computed Properties and Ember's Object Model
over
[here](http://emberjs.com/guides/object-model/computed-properties/).
Happy Coding!
