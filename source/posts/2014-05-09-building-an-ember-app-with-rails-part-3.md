---
layout: post
title: "Building an Ember App with Rails Part 3"
comments: true
author: 'Brian Cardarella'
github: bcardarella
twitter: bcardarella
social: true
published: true
tags: ember, ruby, ruby on rails
ember_start_version: '1.5'
---

*This is a four-part series:
[Part 1](http://reefpoints.dockyard.com/2014/05/07/building-an-ember-app-with-rails-part-1.html),
[Part 2](http://reefpoints.dockyard.com/2014/05/08/building-an-ember-app-with-rails-part-2.html),
[Part 3](http://reefpoints.dockyard.com/2014/05/09/building-an-ember-app-with-rails-part-3.html),
[Part 4](http://reefpoints.dockyard.com/2014/05/31/building-an-ember-app-with-rails-part-4.html)*

Let's implement some navigation in the Boston Ember app.

Here is a list of sections in the Boston Ember website I'd like to add:

* About
* Speakers

For this part we will work with faked out data. In a future part we will
provide the Rails backend.

Our first navigation test will be an easy one, create
`ember/tests/integration/about-page-test.js`

```js
import Ember from 'ember';
import startApp from 'bostonember/tests/helpers/start-app';

var App;

module('Integration - About Page', {
  beforeEach: function() {
    App = startApp();
  },
  afterEach: function() {
    Ember.run(App, 'destroy');
  }
});

test('Should navigate to the About page', function() {
  visit('/').then(function(assert) {
    click("a:contains('About')").then(function(assert) {
      assert.equal(find('h3').text(), 'About');
    });
  });
});
```

After writing this test we can confirm that our test is red in our browser. To make this green we need to add an `About` route, 
a link from the landing page to the `About` route, and a template for the
`About` route.

```js
// ember/app/router.js
Router.map(function() {
  this.route('about');
});
```

```js
// ember/app/templates/application.hbs
<h2 id="title">Welcome to Boston Ember</h2>

{{link-to 'About' 'about'}}

{{outlet}}
```

```js
// ember/app/templates/about.hbs
<h3>About</h3>

<p>Boston Ember is the monthly meetup where awesome people get together
to do awesome Ember related things!</p>
```

Your test should now be green. If you navigate to the root path in your
browser you should be able to click through the app. What about getting
back to root? We can add a test to for this navigation as well.


```js
// ember/tests/integration/landing-page-test.js
test('Should allow navigating back to root from another page', function(assert) {
  visit('/about').then(function() {
    click('a:contains("Home")').then(function(assert) {
      assert.notEqual(find('h3').text(), 'About');
    });
  });
});
```

```js
// ember/app/templates/application.hbs
{{link-to 'Home' 'application'}}
{{link-to 'About' 'about'}}
```

Great! A very simple navigation is setup and fully tested. How about something
more complex. Let's allow our visitors to see the people that have spoken at
Boston Ember. Before we do that we need to add new dependencies to our app for
mocking out remote requests.

We will be using
[Pretender](https://github.com/trek/pretender/tree/0.0.5) by Ember Core
member Trek Glowacki. Pretender is a nice DSL for faking out remote
responses.

We can use the
[ember-cli-pretender](https://github.com/rwjblue/ember-cli-pretender)
Ember CLI Addon to quickly set up Pretender:

```js
npm install --save-dev ember-cli-pretender
ember install:addon ember-cli-pretender
```

You may need to restart your server at this point.

Tell `JSHint` to ignore the `Pretender` constant.  Open up
`ember/tests/.jshintrc` and add `"Pretender"` to the end of the `"predef"`
array.

Finally we need ember-data to make requests namespaced under `api` to
our server:

```js
// ember/app/adapters/application.js
import DS from 'ember-data';

export default DS.ActiveModelAdapter.extend({
  namespace: 'api'
});
```

We should be in a good place to write our tests.

```js
// ember/tests/integration/speakers-page-test.js
import Ember from 'ember';
import startApp from '../helpers/start-app';
import Pretender from 'pretender';

var App, server;

module('Integration - Speaker Page', {
  beforeEach: function() {
    App = startApp();
    var speakers = [
      {
        id: 1,
        name: 'Bugs Bunny'
      },
      {
        id: 2,
        name: 'Wile E. Coyote'
      },
      {
        id: 3,
        name: 'Yosemite Sam'
      }
    ];

    server = new Pretender(function() {
      this.get('/api/speakers', function(request) {
        return [200, {"Content-Type": "application/json"}, JSON.stringify({speakers: speakers})];
      });

      this.get('/api/speakers/:id', function(request) {
        var speaker = speakers.find(function(speaker) {
          if (speaker.id === parseInt(request.params.id, 10)) {
            return speaker;
          }
        });

        return [200, {"Content-Type": "application/json"}, JSON.stringify({speaker: speaker})];
      });
    });

  },
  afterEach: function() {
    Ember.run(App, 'destroy');
    server.shutdown();
  }
});

test('Should allow navigation to the speakers page from the landing page', function(assert) {
  visit('/').then(function() {
    click('a:contains("Speakers")').then(function(assert) {
      assert.equal(find('h3').text(), 'Speakers');
    });
  });
});

test('Should list all speakers', function(assert) {
  visit('/speakers').then(function() {
    assert.equal(find('a:contains("Bugs Bunny")').length, 1);
    assert.equal(find('a:contains("Wile E. Coyote")').length, 1);
    assert.equal(find('a:contains("Yosemite Sam")').length, 1);
  });
});

test('Should be able to navigate to a speaker page', function(assert) {
  visit('/speakers').then(function() {
    click('a:contains("Bugs Bunny")').then(function() {
      assert.equal(find('h4').text(), 'Bugs Bunny');
    });
  });
});

test('Should be able visit a speaker page', function(assert) {
  visit('/speakers/1').then(function() {
    assert.equal(find('h4').text(), 'Bugs Bunny');
  });
});
```

Take a look at the `beforeEach` function. There is an array of objects that contains the speaker data, currently only `id`s and `name`s.
Below that we are setting up the request stubs. Currently this feels
like a lot of boilerplate, and that is because it is. I'm sure
eventually someone will write a nice abstraction to clean this up. This
code simply stubs out the expected server-side calls and returns a JSON
string in the format ember-data expects.

Our four tests are very simple. The first tests the navigation, the 2nd
tests the speakers are in the list, the 3rd tests that we can navigate
to an individual speaker, and the 4th tests that we can visit the speaker page directly.

Let's make each pass:

```js
// ember/app/router.js
Router.map(function() {
  this.route('about');
  this.resource('speakers');
});
```

```hbs
// ember/app/templates/application.hbs
{{link-to 'About' 'about'}}
{{link-to 'Speakers' 'speakers'}}
```

```hbs
// ember/app/templates/speakers.hbs
<h3>Speakers</h3>

{{outlet}}
```

The first test should now be passing.

```js
// ember/app/router.js
Router.map(function() {
  this.route('about');
  this.resource('speakers', function() {
    this.route('show', {path: ':speaker_id'});
  });
});
```

```js
// ember/app/models/speaker.js
import DS from 'ember-data';

export default DS.Model.extend({
  name: DS.attr('string')
});
```

```js
// ember/app/routes/speakers/index.js
import Ember from 'ember';

export default Ember.Route.extend({
  model: function() {
    return this.store.find('speaker');
  }
});
```

```hbs
// ember/app/templates/speakers/index.hbs
{{#each}}
  {{link-to name 'speakers.show' this}}
{{/each}}
```

The 2nd test should now be passing.

```hbs
// ember/app/templates/speakers/show.hbs
<h4>{{name}}</h4>
```

The 3rd & 4th tests should now be passing.

Passing tests are great and all, but let's actually make the app useable by getting our Rails backend
in the game. 

Let's generate a model from our Rails app `rails g model speaker name:string`

Add some seed data:

```ruby
# rails/db/seeds.rb
Speaker.create(name: 'Bugs Bunny')
Speaker.create(name: 'Wile E. Coyote')
Speaker.create(name: 'Yosemite Sam')
```

Create, migrate and seed `rake db:create db:migrate db:seed`.

Add a `speakers` resource under an `api` namespace:

```ruby
# rails/config/routes.rb
namespace :api do
  resources :speakers
end
```

Now add the controller:

```ruby
# rails/app/controllers/api/speakers_controller.rb
class Api::SpeakersController < ApplicationController
  def index
    render json: Speaker.all
  end

  def show
    render json: Speaker.find(params[:id])
  end
end
```

Finally we need to generate a serializer `rails g serializer speaker`.

Add `name` to the list of attributes to serialize

```ruby
class SpeakerSerializer < ActiveModel::Serializer
  attributes :id, :name
end
```

Start your Rails server with port `3000` and restart your ember server with the command 
`ember server --proxy http://localhost:3000`

Any remote requests will be proxied to this location.

Now you can point
your browser to `http://localhost:4200`, click on `Speakers` and you
should see:

![Screen1](http://i.imgur.com/dcdkJDo.png)

That wraps up Part 3. In [Part 4](http://reefpoints.dockyard.com/2014/05/31/building-an-ember-app-with-rails-part-4.html) we will get into relationships.

[Check out the actual code for this
part](https://github.com/bostonember/website/commit/a21e06a9a29b19d405e50268a6d276b8db758261)
