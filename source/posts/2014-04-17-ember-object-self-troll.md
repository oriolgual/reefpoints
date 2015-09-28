---
layout: post
title: 'Ember Object Self Troll'
twitter: twokul
github: twokul
author: 'Alex Navasardyan'
tags: ember
social: true
published: true
comments: true
summary: 'Ember.Object.create explained'
ember_start_version: '1.5'
---

Let's say we have a `Month` object. A `Month` has `weeks`.

```javascript
var Month = Ember.Object.extend({
  weeks: Em.A()
});
```

Consider the following code:

```javascript
var a = Month.create();
var b = Month.create();

console.log('before a', a.get('weeks')); // => []
console.log('before b', b.get('weeks')); // => []

a.get('weeks').pushObject(1);
a.get('weeks').pushObject(2);

console.log('after a', a.get('weeks')); // => [1, 2], as you expect
console.log('after b', b.get('weeks')); // => [1, 2], and you're like O_o
```

And another one:

```javascript
var Month = Ember.Object.extend({
  weeks: Em.A()
});

var a = Month.create({ weeks: Em.A([1, 2]) });
var b = Month.create();

console.log('a', a.get('weeks')); // => [1, 2]
console.log('b', b.get('weeks')); // => []
```

The results of the first example are quite surprising, if you are not used
to the prototypical inheritance.

So what's going on there? Let's take a look at the "very scary" Ember.js `create` [function](https://github.com/emberjs/ember.js/blob/master/packages_es6/ember-metal/lib/platform.js#L39-L52):

```javascript
create = function(obj, props) {
  K.prototype = obj;
  obj = new K();
  if (props) {
    K.prototype = obj;
    for (var prop in props) {
      K.prototype[prop] = props[prop].value;
    }
    obj = new K();
  }
  K.prototype = null;

  return obj;
};
```

When you don't pass any properties to create (`props`), all instances of
the `Object` will share the same prototype. That's pretty much the gist
of the prototypical inheritance. It means that any changes on one object will
reflect on the others. That explains the behaviour in the first example.

If you pass the properties (that ones that you specified at `extend` time) to `create`,
they are going to be replaced on the instance's prototype.

There are two ways of changing the default behavior:

+ turn `weeks` into a [Computed Property](http://reefpoints.dockyard.com/2013/09/04/computed_properties_in_ember_js.html)
+ set `weeks` on `init`

Using computed property:

```javascript
var Month = Ember.Object.extend({
  weeks: Ember.computed(function() {
    return Em.A();
  })
});
```

In this case, `weeks` is going to return a new `Ember.Array` on `get`.
The code will run as you expect, `weeks` are not going to be shared.

Using `init`:

```javascript
var Month = Ember.Object.extend({
  weeks: null,

  init: function() {
    this._super();
    this.set('weeks', Em.A());
  }
});
```

This is very clear and nice technique if you're not familiar with computed properties.
Overriding `init` and calling `super` allows to run code upon the object's creation.
You can set the value for `weeks` there.

You can also use `on('init')` but it's discouraged because a subclass can provide
its own implementation of `setWeeks`:

```javascript
var Month = Ember.Object.extend({
  setWeeks: function() {
    this.set('weeks', Em.A());
  }.on('init')
});
```

Happy coding!
