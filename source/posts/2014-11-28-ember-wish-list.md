---
layout: post
title: "Ember Wish List"
comments: true
author: 'Brian Cardarella'
twitter: 'bcardarella'
social: true
published: true
tags: ember, opinion
ember_start_version: '1.8'
---

It's getting close to Christmas and I've got a few things on my list for
Tomster Claus this year. All of my wishes are about making my
applications smaller. One of the constant complaints I see about Ember
is that it is "too fat". You may not know this but this problem is
solveable and can actually grow alongside Ember to ensure your assets
are a slim as they can be. On to the wish list!

### Tree Shaking

Are you familiar with Tree Shaking? The concept is simple, a dependency
graph of your application is built. Let's say one of your files requires
`A`, `B`, and `C`. And `A` requires `D`, and `F`. And `C` required `F`.
Currently with Ember CLI all files for all of your dependencies will get
included in the final build. So if there is an `E` file it will be in
the final build even if you are not using it in any way, this is wasteful.
With ES6 the dependency graph can be built between your files, any files
that are not in the graph are not included in the final built. They are
"shaken" out of the build process. This means a smaller footprint for your assets.

There are two major hurdles to implementing this in Ember CLI right now.
The first is that doing a static analysis on the dependency graph may
result in false positives of what files to ignore for the build. While
there are many files that you are depending upon via the `import`
statement:

```javascript
import { foo, bar } from 'baz';
```

This is very easy to parse. But your application can also import
resources via the Ember Resolver:

```javascript
container.lookup('model:foo');
```

A few levels down a `resolveOther` function is called and `lookup` is
turned into a `require`:

```javascript
require('my-app/models/foo');
```

parsing this out is not as simple. We could just assume everything in
the app's namespace should be part of the final build, but when other
libraries are doing more complex tricks with importing this presents a
problem. For example, in the latest version of Ember Validations the
validators themselves live in the `ember-validations` namespace. You can
override validators by placing them in your namespace. The lookup is
something like this:

```javascript
function lookupValidator(name) {
  return container.lookup('validator:'+name) ||
    container.lookup('ember-validations@validator:'+name);
}
```

How do we properly parse this out to include the correct validators in
the dependency graph? One solution might be for library authors to
declare which files should always be included in the final build, but
this defeats the purpose of only including what is being used. If the
application is using the Presence Validator but not the Inclusion
Validator why would I want those extra LOCs?

The other major hurdle is Ember itself. While Ember's source is in ES6
form the final build that you get is in AMD. Which means it is one file.
Ember will have to be distributed in the original ES6 form. I am also
not a fan of the current package names. If this ever happens I would
much prefer:

```javascript
import Component from 'ember/component';
```

rather than

```javascript
import Component from `ember-views/views/component';
```

### Separate builds

Ember CLI is all or nothing right now. Which means that you have a
single build pipeline for your application assets (`app-name.js`) and a single build
pipeline for 3rd party assets (`vendor.js`). It would be nice to define
additional assets that can be built into final files. For example, [this
request for Ember
Admin](https://github.com/dockyard/ember-admin/issues/32). Technically
this could be done right now but it would require some heavy hacking of
the vendor asset pipeline in Ember CLI. Personally I would like to see
an API for this specifically. Perhaps it could be in the form of isolating a namespace to
be ignored in the `vendor.js` final concat but still output in the
`dist/` directory.

### Async code loading

This wish dove-tails off the previous one. Now that we have our separate
assets how do we safely load them into our Ember apps? If we are
isolating the assets I would think this implies they aren't meant for
consumption at application launch. Going back to the Ember Admin
example, not all users need those LOCs. Only when an authorized user
hits the admin functionality should it pull down the Ember Admin assets
and plug into the app. This would be ideal. The major hurdle here is
with how the container currently works. Perhaps something like this
could put it on the right track:

```javascript
resolveOther: function(name) {
  if (needAsyncLoad(name)) {
    asyncLoad(name).then(function() {
      // after this load completes the name
      // would be removed from the list of
      // resources requiring async loading
      resolveOther(name);
    }
  } else {
    return require(name);
  }
}
```

This would allow even further shrinking of the initial applicaiton
footprint. Only include what is necessary, async load other assets. This
creates the illusion of speed which is just as good as actual speed. You
will have the trade-off of periodic sections of your app with a longer
than normal loading state, but that should only happen once per
application instance.

### Wishes to reality

Fulfilling these wishes should go a long way to negating the "too fat" argument for
Ember. Here's to hoping that 2015 will see a more lean Tomster.
