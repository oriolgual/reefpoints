---
layout: post
title: "Building an Ember App with Rails Part 2"
comments: true
author: 'Brian Cardarella'
github: bcardarella
twitter: bcardarella
social: true
summary: Writing our first ember test
published: true
tags: ember, ruby, ruby on rails
ember_start_version: '1.5'
---

*This is a four-part series:
[Part 1](http://reefpoints.dockyard.com/2014/05/07/building-an-ember-app-with-rails-part-1.html),
[Part 2](http://reefpoints.dockyard.com/2014/05/08/building-an-ember-app-with-rails-part-2.html),
[Part 3](http://reefpoints.dockyard.com/2014/05/09/building-an-ember-app-with-rails-part-3.html),
[Part 4](http://reefpoints.dockyard.com/2014/05/31/building-an-ember-app-with-rails-part-4.html)*

From your project directory root, go to your ember directory and start your server:

```bash
cd ember
ember server
```

Open your browser and go to: `http://localhost:4200/tests`

You should see something like the following:

![Screen 1](http://i.imgur.com/bufKV2c.png)

This is a typical [Qunit](http://qunitjs.com/) test suite with some
[JSHint](http://www.jshint.com/) tests already in our app. What you'll notice in the lower
right-hand corner is a blank white box. This box is where our
integration tests will execute. This is an IFRAME so we can see our
applications interacted with in real-time (albeit very fast real-time).

Let's build out a landing page for our app. We will TDD this entire
application over this multi-part series. Create a new directory and file
`ember/tests/integration/landing-page-test.js`.

All of our files will be in
[ES6
module](http://wiki.ecmascript.org/doku.php?id=harmony:specification_drafts)
format. If you are unfamiliar with ES6 modules I suggest you go and read
up.

```js
import Ember from 'ember';
import { module, test } from 'qunit';
import startApp from '../helpers/start-app';

var App;

module('Integration - Landing Page', {
  beforeEach: function() {
    App = startApp();
  },
  afterEach: function() {
    Ember.run(App, 'destroy');
  }
});

test('Should welcome me to Boston Ember', function(assert) {
  visit('/').then(function() {
    assert.equal(find('h2#title').text(), 'Welcome to Boston Ember');
  });
});
```

Once you save this file go back to your browser. You should not need to reload anything, ember-cli has a live reload feature on file
change. Now you should see your failing test:

![Screen2](http://i.imgur.com/l7y146I.png)

Let's make the test pass:

In `ember/app/templates/application.hbs`

```hbs
<h2 id="title">Welcome to Boston Ember</h2>
{{outlet}}
```

Check your test suite and it should be all green.

![Screen3](http://i.imgur.com/242RLGf.png)

Congratulations on your first ember test!

In [part 3](http://reefpoints.dockyard.com/2014/05/09/building-an-ember-app-with-rails-part-3.html) we'll build out some pages and write tests to interact with
these pages.

[Check out the actual code for this
part](https://github.com/bostonember/website/commit/b17a67b9368acec29c88f4aaa83eceb82a9f143d)
