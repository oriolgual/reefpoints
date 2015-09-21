---
layout: post
title: "Bringing Ember to the Desktop with NW.js"
comments: true
twitter: "edeblois"
github: "brzpegasus"
author: "Estelle DeBlois"
tags: ember
social: true
published: true
---

One of our recent client projects at DockYard had us go in a totally new
direction in terms of technology stack. We needed to build a desktop
application that could communicate with some Arduino devices via
[WebSockets](https://developer.mozilla.org/en-US/docs/WebSockets).

Let me first put this out there: I love building for the web. The mere
thought of developing native desktop applications always makes me cringe
a little, though I admit, I haven't done much in that arena since those
[Java Swing](http://en.wikipedia.org/wiki/Swing_%28Java%29) days from forever ago.
Nevertheless, you may find yourself at some point needing to build for the desktop.
Thankfully, you don't have to put your fuzzy little Tomster away.

[NW.js](https://github.com/nwjs/nw.js), formerly known as Node WebKit, is a runtime
built on top of Chromium and Node/IO.js that lets you develop native applications
using the web technologies that you love. You can essentially build an Ember app, and
also invoke Node modules all within the browser, then package it up as
a Mac OS X application or Windows `exe` file when you're ready to distribute.

## Demo

Here's a screenshot from a NW.js app built with Ember for demonstration
purposes:

![screenshot](https://cloud.githubusercontent.com/assets/1691398/6768192/536a6fde-d033-11e4-9375-e2f506c1c8c7.png)

It's a simple GitHub-flavored Markdown Editor that lets you create and preview
Markdown documents, and save them to disk.

You can try it for yourself. Just download the application from the
following links for your platform, unzip, then double-click on `Markdown
Editor.app` (Mac) or `Markdown Editor.exe` (Windows).

* Mac OS X: [markdown-editor-osx64](https://s3.amazonaws.com/dockyard-general/ember-nw-demo/markdown-editor-osx64.zip)
* Windows:
[markdown-editor-win64](https://s3.amazonaws.com/dockyard-general/ember-nw-demo/markdown-editor-win64.zip)
* [Source code](https://github.com/brzpegasus/ember-nw-markdown)

For a touch of user friendliness, the app even ships with your favorite
mascot:

_Mac:_
<img alt="Mac Icon" src="https://cloud.githubusercontent.com/assets/1691398/6853610/9ee8c52c-d3c2-11e4-971a-3472bfd35609.png">

<em style="display: block;">Windows:</em>
<img alt="Windows Icon" src="https://cloud.githubusercontent.com/assets/1691398/6853614/a32becc2-d3c2-11e4-9ed4-83d645825f4b.png">

## Getting Started

The main entry point to a NW.js application is an HTML page that you
specify in your project's `package.json`:

```json
{
  "name": "my-app",
  "main": "dist/index.html"
}
```

On startup, NW.js will launch a new Chromium browser window,
then set the location to that starting page:
`file:///Users/brzpegasus/projects/my-app/dist/index.html#/`.

This does require that you set your `Ember.Router`
[location type](http://emberjs.com/api/classes/Ember.Location.html) to `hash`. In Ember CLI,
this is a simple tweak to your `config/environment.js` file:

```javascript
// config/environment.js
modules.exports = function(environment) {
  var ENV = {
    locationType: 'hash', // Change this from 'auto' to 'hash'
    // ...
  };
};
```

From there on, you should feel quite at home and ready to develop your Ember app.

Or maybe not quite yet.

## A Bit About NW.js

NW.js tweaks Chromium and Node in order to
[integrate](https://github.com/nwjs/nw.js/wiki/How-node.js-is-integrated-with-chromium)
the two worlds and make it possible for you to call Node modules from the client:

```javascript
console.log(location.href);   // Yup, we're in browser land

var fs = require('fs');       // Call core Node modules
var async = require('async'); // Or even third-party modules!
```

If you're used to Node and CommonJS, this `require` function should look very
familiar, but it isn't exactly the same. Here's what it does:

```javascript
function require(name) {
  if (name == 'nw.gui')
    return nwDispatcher.requireNwGui();
  return global.require(name);
}
```

So if you were to call `require('nw.gui')`, you would get access to the
[Native UI Library](https://github.com/nwjs/nw.js/wiki/Native-UI-API-Manual)
to do things like manipulating the window frame, adding menus, keyboard shortcuts, etc.
Otherwise, the function ends up calling `global.require` to import Node modules.

`global` is Node's global namespace object. You can use it to retrieve
other global objects besides `require`, such as `global.process`.
However, many of them are made available directly on the `window` object, so you can
reference them without prefix, just as you would in Node:

```javascript
console.log(window.process === global.process) // => true
console.log(process.env.USER) // "brzpegasus"
console.log(process.platform) // "darwin"
```

## Naming Conflicts

Modules written with ES2015 ([previously, ES6](https://esdiscuss.org/topic/javascript-2015#content-3))
syntax in your Ember app get transpiled into
AMD for today's browsers. This is problematic because AMD also specifies a
`require` function for loading modules. In Ember CLI, this is implemented via
[ember-cli/loader.js](https://github.com/ember-cli/loader.js).

By the time the app is done loading, any functionality that depends on
the native UI library or Node modules will break as the `require`
function would have been redefined.

You can get around this by saving a reference to Node's `require` before loading
any script. Once all scripts are loaded and executed, redefine `require`
to work with both module systems. This is necessary as certain operations
will not work with the alias:

```javascript
// Before loading any script
window.requireNode = require;

// After all scripts are loaded
var requireAMD = require;

window.require = function() {
  try {
    return requireAMD.apply(null, arguments);
  } catch (error) {
    return requireNode.apply(null, arguments);
  }
};
```

## An Addon For All Your NW.js Needs

I've recently released an Ember CLI addon to help make this process
easier. Simply install [ember-cli-node-webkit](https://github.com/brzpegasus/ember-cli-node-webkit),
then start coding right away. All the configuration will be taken care
of for you, so no need to worry about `require` naming conflicts.

The addon can build your project, watch for changes, and reload the page in NW.js
during development. And when you're ready to distribute, packaging is just
one command away. The packaging is a wrapper around the excellent
[node-webkit-builder](https://github.com/mllrsohn/node-webkit-builder)
but the configuration is done automatically based on the addon's
understanding of your app structure.

I will not spend time talking about the addon in this blog post, but I
invite you to check out the [README](https://github.com/brzpegasus/ember-cli-node-webkit/blob/master/README.md)
to get familiar with all the options that are at your disposal.

## Conclusion

When we first set out to build a desktop app for a client project,
documentation on how to integrate NW.js with Ember was scarce. Even more
scarce was documentation on how to integrate it with Ember CLI. I hope
this post and this addon will provide some guidance to others down the
road.

I'd love to share some code samples and discuss patterns you can adopt
to make your NW.js app more manageable and testable, but they'd be too
dense for this introductory blog post. However, you'll be hearing more from me
on this topic in the future!
