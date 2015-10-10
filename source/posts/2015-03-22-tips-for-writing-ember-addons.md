---
layout: post
title: "Tips for writing Ember Addons"
comments: true
author: 'Brian Cardarella'
twitter: 'bcardarella'
social: true
published: true
tags: ember, javascript
ember_start_version: '1.10'
---

After having published many Ember addons I have started to develop my
own sense of "Best Practices" and I'd like to share those with you:

## 1. Keep it minimal, don't include stylesheets

I see quite a few addons out there that include their own look & feel by
including sytlesheets. I actually think this is a bad idea. *Keep in
mind, every line of code you put into your addon will end up in the
final footprint of the apps consuming it*. This means if you are
including stylesheets those will end up in `vendor.css`. The odds are
that whatever styles you decide look good, someone else might not.
They'll waste even more space by including their own overrides. This is
wasteful.

Instead, you should *keep it minimal*. See
[ember-admin](https://github.com/dockyard/ember-admin). I intentionally
did not style the addon so it is left as minimal as possible. If you
want to show off a styled version of the addon, you can either include
styles in the dummy app's styles for the addon's test dummy. Allow
people to run the addon's server locally and view what could be. Or, you
can include an addon wrapper library that depends upon your addon. This
wrapper can include default styles that consumers may choose not to
alter. For example,
[ember-admin-bootstrap](https://github.com/dockyard/ember-admin-bootstrap)
styles ember-admin with Twitter Bootstrap. If this is good enough for
you then you just install this library and it pulls in ember-admin but
gives you some nice styling that you don't have to spend time doing.

## 2. Allow for overrides

I believe strongly in composable addons. A consumer should have the
ability to easily extend your addon to do whatever they want. This means
organizing your code a certain way. To provide this you should put all
of your business logic into `addon/` and then include wrapper classes in
`app/` that just `import` then `export` the extended class. For example:

```javascript
// addon/components/foo-bar.js
import Ember from 'ember';
export default Ember.Component.extend({
  // business logic
});

// app/components/foo-bar.js
import FooBar from 'my-addon/components/foo-bar';
export default FooBar;
```

These light wrapper classes **should not** include any business logic.
Again, they simply `import` then `export` the extended class. This gives
consumers the option of overriding this in their own
`app/components/foo-bar.js` file to extend and add customization.

## 3. Turn off Prototype Extensions

Currently ember-cli will not generate an addon project with Prototype
Extensions turn off. However, [I have requested this be the
default](https://github.com/ember-cli/ember-cli/issues/3443). Turning
off Prototype Extensions will cause the following syntax to fail in
your addon's test suite:

```javascript
foo: function() {
  // whatever
}.property('bar')
```

There are several syntax shortcuts that Ember injects into the base
Types. Arrays have quite a bit. Turning off Prototype Extensions will
force you to write the above code as:

```javascript
foo: Ember.computed('bar', function() {
  // whatever
})
```

And this will play nice with consumer applications that must run with
the Prototype Extensions turned off.

[It should be noted that Ember 1.10 has a bug where turning off Prototype
Extensions causes Ember itself to
fail](https://github.com/emberjs/ember.js/issues/10590). This should be
fixed in 1.11 (**Update: This has been addressed in [Ember](https://github.com/emberjs/ember.js/pull/10697).**).

Avoiding Prototype Extensions can be difficult. I plan on writing a
future blog post to outline certain strategies to duplicate the behavior
that you miss out on without Prototype Extensions.

To turn off Prototype Extensions you'll need to install the `ember-disable-prototype-extensions`:

```
npm install --save-dev ember-disable-prototype-extensions
```

See
[ember-validations](https://github.com/dockyard/ember-validations/pull/270)
for an example.

## 4. Test your addon

This one should go without saying but I have seen *way* too many addons
out there that are untested (the generated tests don't count). Please
keep in mind that there are people building products that might consume
your work. Untested code is just one more thing that could go wrong in
someone's app. If unit testing the code is too difficult, at the very
least write integration tests against the dummy application to ensure
the happy paths.

## 5. Depend on other addons

You may not know this but addons can depend upon addons. Rather than
recreating behavior per-addon it would be best to extract out common
behavior to its own dependency. For example,
[ember-data-route](https://github.com/dockyard/ember-data-route) and
[ember-cli-async-button](https://github.com/dockyard/ember-cli-async-button)
are both being used in
[ember-admin](https://github.com/dockyard/ember-admin/blob/master/package.json#L21-L23).

To use an addon as a dependency it *must* be put into the `dependencies`
object in `package.json`, **not** `devDependencies`. You may need to
add this keyword to your `package.json` as it is not part of the
auto-generated file.

Ember's addon eco-system is getting better every day, and as a community
we are learning as we grow how best to build and maintain addons. I'm
hoping you find these tips helpful. Please feel free to share your own
in the comments below. 
