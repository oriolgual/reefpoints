---
layout: post
title: "Building an Ember App with Rails Part 4"
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

Before we get underway we need to update ember-data in our project to at
least `1.0.0-beta.8`. Open `ember/bower.json` and if you have any version
less than 8 you'll need to update to at least 8. If you are already on 8
or higher you won't need to do anything.

Once you've made the change save the file and run `bower install` from
the `ember/` directory. If you are asked to choose between different
versions of ember-data make sure you choose the correct one.

In this part we'll add Presentations to each of the Speaker pages. This
means we'll have to add a relationship between two models.

In `ember/tests/integration/speakers-page-test.js` modify the test
"Should list all speakers and number of presentations"

```javascript
// ember/tests/integration/speaker-page-test.js

test('Should list all speakers and number of presentations', function() {
  visit('/speakers').then(function(assert) {
    assert.equal(find('a:contains("Bugs Bunny (2)")').length, 1);
    assert.equal(find('a:contains("Wile E. Coyote (1)")').length, 1);
    assert.equal(find('a:contains("Yosemite Sam (3)")').length, 1);
  });
});
```

The number in the parentheses will represent the number of presentations that this speaker 
has given.

Next we need to modify our `beforeEach` function

```javascript
// ember/tests/integration/speaker-page-test.js

var speakers = [
  { id: 1, name: 'Bugs Bunny', presentation_ids: [1,2] },
  { id: 2, name: 'Wile E. Coyote', presentation_ids: [3] },
  { id: 3, name: 'Yosemite Sam', presentation_ids: [4,5,6] }
];

var presentations = [
  { id: 1, title: "What's up with Docs?", speaker_id: 1 },
  { id: 2, title: "Of course, you know, this means war.", speaker_id: 1 },
  { id: 3, title: "Getting the most from the Acme categlog.", speaker_id: 2 },
  { id: 4, title: "Shaaaad up!", speaker_id: 3 },
  { id: 5, title: "Ah hates rabbits.", speaker_id: 3 },
  { id: 6, title: "The Great horni-todes", speaker_id: 3 }
];

server = new Pretender(function() {
  this.get('/api/speakers', function(request) {
    return [200, {"Content-Type": "application/json"}, JSON.stringify({speakers: speakers, presentations: presentations})];
  });

  this.get('/api/speakers/:id', function(request) {
    var speaker = speakers.find(function(speaker) {
      if (speaker.id === parseInt(request.params.id, 10)) {
        return speaker;
      }
    });

    return [200, {"Content-Type": "application/json"}, JSON.stringify({speaker: speaker, presentations: presentations})];
  });
});
```

Completely replace the `speakers` variable that was previously there. The only change to the API stub is that
`presentations` is being added to the payload. The JSON here is the
style of JSON that ember-data expects to be emitted. We are returning a
payload that includes all speakers and presentations. The speaker
records include ids referencing the presentations associated.

We can now add the Presentation model to our Ember app:

```javascript
// ember/app/models/presentation.js
import DS from 'ember-data';

export default DS.Model.extend({
  title: DS.attr('string'),
  speaker: DS.belongsTo('speaker')
}); 
```

We've told ember-data to expect the Presentation model to belong to the
Speaker model. Let's set the inverse relationship

```javascript
// ember/app/models/speaker.js
import DS from 'ember-data';

export default DS.Model.extend({
  name: DS.attr('string'),
  presentations: DS.hasMany('presentation')
});
```

Modifying our existing Speaker model to add to relationship to its many
Presentation models.

Finally to make this tests green we need to change our template:

```handlebars
// ember/app/templates/speakers/index.hbs

{{#each}}
 {{~#link-to 'speakers.show' this}}
   {{name}} ({{presentations.length}})
 {{~/link-to}}
{{/each}}
```

Notice that we we can call regular JavaScript properties like `length` on the association.
There is also a slight change that I've made to the `link-to`. Adding
`~` will [tell Handlebars how to control
whitespace](http://handlebarsjs.com/block_helpers.html#whitespace-control).

At this point our new test should be green. Lets add another.

```javascript
// ember/tests/integration/speaker-page-test.js

test('Should list all presentations for a speaker', function(assert) {
  visit('/speakers/1').then(function(assert) {
    assert.equal(find('li:contains("What\'s up with Docs?")').length, 1);
    assert.equal(find('li:contains("Of course, you know, this means war.")').length, 1);
  });
});
```

This new test is asserting that when we visit a given speaker's page all
of those speaker's presentations will be listed. We first need to add
presentation data to the API stub (within our `beforeEach` function) for visiting a speaker page.

```javascript
// ember/tests/integration/speaker-page-test.js

this.get('/api/speakers/:id', function(request) {
  var speaker = speakers.find(function(speaker) {
    if (speaker.id === parseInt(request.params.id, 10)) {
      return speaker;
    }
  });

  var speakerPresentations = presentations.filter(function(presentation) {
    if (presentation.speaker_id === speaker.id) {
      return true;
    }
  });

  return [200, {"Content-Type": "application/json"}, JSON.stringify({speaker: speaker, presentations: speakerPresentations})];
});
```

This modification of the previously existing stub will build a new payload object that
includes the speaker matching the id requested and all of the
presentations specific to that speaker.

Tying up this test is easy now, we just modify the Speaker's `show`
template:

```handlebars
<h4>{{name}}</h4>

<h5>Presentations</h5>
<ul>
  {{#each presentations}}
    <li>{{title}}</li>
  {{/each}}
</ul>
```

Now that we have a green test suite with our mocked out API let's add the
real Rails endpoint. We'll start by generating a new Presentation model.
Change to the `rails/` directory in your project and run `rails generate
model presentation title:string speaker_id:integer`.

Next we'll generate the serializer: `rails generate serializer
presentation`.

Let's expand upon the `rails/db/seeds.rb` file:

```ruby
# rails/db/seeds.rb

bugs = Speaker.create(name: 'Bug Bunny')
wile = Speaker.create(name: 'Wile E. Coyote')
sam  = Speaker.create(name: 'Yosemite Sam')

bugs.presentations.create(title: "What's up with Docs?")
bugs.presentations.create(title: "Of course, you know, this means war.")

wile.presentations.create(title: "Getting the most from the Acme categlog.")

sam.presentations.create(title: "Shaaaad up!")
sam.presentations.create(title: "Ah hates rabbits.")
sam.presentations.create(title: "The Great horni-todes")
```

Tell our `Speaker` model that there is a relationship to `Presentation`
models:

```ruby
# rails/app/models/speaker.rb

class Speaker < ActiveRecord::Base
  has_many :presentations
end
```

Finally we need to modify the serializers.

```ruby
# rails/app/serializers/presentation_serializer.rb

class PresentationSerializer < ActiveModel::Serializer
  attributes :id, :title
end
```

```ruby
# rails/app/serializers/speaker_serializer.rb

class SpeakerSerializer < ActiveModel::Serializer
  embed :ids, include: true

  attributes :id, :name
  has_many :presentations
end
```

In the `SpeakerSerializer` we have instructed the serializer to include
the associated `Presentation`s.

Let's reset the database and re-seed `rake db:drop db:create db:migrate db:seed`

Make sure you are running your Ember server with the proxy enabled:
`ember server --proxy http://localhost:3000`

Now you can hit your application and you should have a all of the
necessary data. 

![image1](http://i.imgur.com/jmHGxgS.png)
![image2](http://i.imgur.com/plrKLvg.png)

[Check out the actual code for this
part](https://github.com/bostonember/website/commit/10f838ff1bfb0aa1307d4de6587889489697c8da)
