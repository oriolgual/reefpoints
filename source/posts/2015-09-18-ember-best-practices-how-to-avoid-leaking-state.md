---
layout: post
title: "Ember Best Practices: How to avoid leaking state into factories"
twitter: edeblois
github: brzpegasus
author: "Estelle DeBlois"
tags: ember, javascript
social: true
comments: true
published: true
---

At DockYard, we spend our days writing code with Ember, from building web apps, to creating and maintaining addons, and contributing back to the Ember ecosystem. We hope to share some of the experience we've gathered along the way through a series of blog posts that will focus on idiomatic Ember practices, patterns, anti-patterns, and common pitfalls. This is the first in that series, so let's start by going back to the basics with `Ember.Object`.

`Ember.Object` is one of the first things we learn as Ember developers, and to no surprise. Pretty much every object we work with in Ember, whether it's a route, component, model, or service, [extends from Ember.Object](http://emberjs.jsbin.com/boqapo). But every now and then, I see it used incorrectly, like this:

```js
export default Ember.Component.extend({
  items: [],

  actions: {
    addItem(item) {
      this.get('items').pushObject(item);
    }
  }
});
```

To those who have encountered this before, the problem is obvious. But I'm sure this has trolled many developers at one time or another, so if the issue doesn't immediately jump at you, keep reading!

## Ember.Object

If you were to browse the [API](http://emberjs.com/api/classes/Ember.Object.html) and deselect all _Inherited_, _Protected_, and _Private_ options, you'll see that `Ember.Object` has no methods or properties of its own. The [source](https://github.com/emberjs/ember.js/blob/v2.0.2/packages/ember-runtime/lib/system/object.js) code couldn't be any shorter. It's literally just an extension of Ember's `CoreObject`, with the `Observable` mixin applied:

```js
var EmberObject = CoreObject.extend(Observable);
```

`CoreObject` provides a clean interface for defining factories or _classes_. It is essentially an abstraction around how you would normally create constructor functions, define methods and properties on the prototype, and then create new objects by calling `new SomeConstructor()`. If you're able to invoke methods of a superclass using `this._super()`, or merge a set of properties into a class via [Mixins](http://emberjs.com/api/classes/Ember.Mixin.html), you have `CoreObject` to thank for. All the methods that come up often when working with Ember objects, such as `init`, `create`, `extend`, or `reopen`, are all defined there too.

`Observable` is the mixin that makes it possible to observe changes to properties on an object, and is where both `get` and `set` methods come from.

When developing an Ember app, you would never use `CoreObject` directly. You would extend from `Ember.Object` instead. After all, Ember is all about [reacting to changes](https://medium.com/the-ember-way/ember-js-reactive-programming-computed-properties-and-observers-cf80c2fbcfc), so you need the methods from `Observable` in order to detect when a property value changes.

## Defining a new class

You can define a new type of observable object by extending from `Ember.Object`:

```js
const Post = Ember.Object.extend({
  title: 'Untitled',
  author: 'Anonymous',

  header: computed('title', 'author', function() {
    const title = this.get('title');
    const author = this.get('author');
    return `"${title}" by ${author}`;
  })
});
```

New objects of type `Post` can now be created by calling `Post.create()`. Each post instance will inherit the properties and methods that have been defined on the `Post` class:

```js
const post = Post.create();
post.get('title'); // => 'Untitled'
post.get('author'); // => 'Anonymous'
post.get('header'); // => 'Untitled by Anonymous'
post instanceof Post; // => true
```

You can change the property values and give the post a meaningful title and author name. These values will be set on the instance, not the class, and therefore will not affect future posts that get created.

```js
post.set('title', 'Heads? Or Tails?');
post.set('author', 'R & R Lutece');
post.get('header'); // => '"Heads? Or Tails?" by R & R Lutece'

const anotherPost = Post.create();
anotherPost.get('title'); // => 'Untitled'
anotherPost.get('author'); // => 'Anonymous'
anotherPost.get('header'); // => 'Untitled by Anonymous'
```

Because updating properties this way has no impact on other instances, it is easy to think that all operations done on an instance are safe. But let's expand on this example a bit more.

## Leaking state into the class

A post can have an optional list of tags, so we can create a property named `tags` and default it to an empty array. New tags can be added by calling an `addTag()` method.

```js
const Post = Ember.Object.extend({
  tags: [],

  addTag(tag) {
    this.get('tags').pushObject(tag);
  }
});

const post = Post.create();
post.get('tags'); // => []
post.addTag('constants');
post.addTag('variables');
post.get('tags'); // => ['constants', 'variables']
```

Looks like it's working! But check out what happens when a second post is now created:

```js
const anotherPost = Post.create();
anotherPost.get('tags'); // => ['constants', 'variables']
```

Even though the goal was to create a new post with empty tags (the intended default), the post was created with the tags from the previous post. Because we never set the post's `tags` property to a new value but simply mutated the underlying array, we have effectively leaked state into the `Post` class, which is then shared by all instances.

```js
post.get('tags'); // => ['constants', 'variables']
anotherPost.get('tags'); // => ['constants', 'variables']
anotherPost.addTag('infinity'); // => ['constants', 'variables', 'infinity']
post.get('tags'); // => ['constants', 'variables', 'infinity']
```

It is not the only scenario where you may confuse instance state and class state, but it is certainly one that comes up more often. In a related example, you may wish to default an object's property named `createdDate` to the current date and time by setting it to `new Date()`. But `new Date()` will only get evaluated once, when the class is defined. So no matter when you create new instances of that class, they will all share the same `createdDate`:

```js
const Post = Ember.Object.extend({
  createdDate: new Date()
});

const postA = Post.create();
postA.get('createdDate'); // => Fri Sep 18 2015 13:47:02 GMT-0400 (EDT)

// Sometime in the future...
const postB = Post.create();
postB.get('createdDate'); // => Fri Sep 18 2015 13:47:02 GMT-0400 (EDT)
```

## Keeping things under control

In order to avoid sharing tags between posts, the `tags` property would need to be set when the object is initialized:

```js
const Post = Ember.Object.extend({
  init() {
    this._super(...arguments);
    this.tags = [];
  }
});
```

Since `init` is called whenever you call `Post.create()`, each post instance will always get its own `tags` array. Alternatively, you could make `tags` a computed property. It won't observe anything, but will be unique to each instance:

```js
const Post = Ember.Object.extend({
  tags: computed({
    return [];
  })
});
```

## Conclusion

It should be obvious now why you should not write components like the example I showed at the beginning of this post. Even if the component only appears once on a page, when you leave the route, only the component instance gets destroyed, not the factory. So when you come back, a new instance of the Component will get created, and this new component will have traces of the previous time you visited the page.

This error may be encountered when using mixins as well. Even though `Ember.Mixin` is not an `Ember.Object`, properties and methods defined on the mixin get merged with the `Ember.Object` you mix it into. The result would be the same: you may end up sharing state between all objects that use the mixin.

If you found this post helpful, stay tuned for more blog posts from myself and fellow DockYarders on Ember best practices in the future!
