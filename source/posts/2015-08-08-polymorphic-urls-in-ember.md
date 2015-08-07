---
layout: post
title: "Polymorphic URLs in Ember"
social: true
author: "Brian Cardarella"
twitter: bcardarella
github: bcardarella
published: true
tags: ember, javascript
---

Ember makes it easy to consume polymorphic records, assuming you have
the following data retrieved from your server:

```json
{
  "data": [
    {
      "id": 1,
      "type": "hooman",
      "relationships": {
        "pet": {
          "data": {
            "type": "cat",
            "id": 1
          }
        }
      }
    }, {
      "id": 2,
      "type": "hooman",
      "relationships": {
        "pet": {
          "data": {
            "type": "dog",
            "id": 3
          }
        }
      }
    }
  ]
}
```

Let's put aside my contrived data model for a minute, the point is that
in this set the `pet` relationship for the `hooman` can be of type
`cat` or `dog`. We can handle this in Ember Data by first
creating a `pet` model:

```js
import DS from 'ember-data';

const {
  attr,
  belongsTo,
  Model
} = DS;

export default Model.extend({
  name: attr('string'),
  hooman: belongsTo('hooman') 
});
```

Then in the `hooman` model:

```js
import DS from 'ember-data';

const {
  attr,
  belongsTo,
  Model
} = DS;

export default Model.extend({
  pet: belongsTo('pet', { polymorphic: true })
});
```

This will instruct the relationship to look at the `type` property to
determine the model type. You can then access through the `pet`
property:

`get(hooman, 'pet') // <cat-model>`

Ok, this was probably review for some people. I recently ran into an
issue where I needed to do a `link-to` for a polymorphic relationship. Using
our same example, I would have done:

```hbs
{{link-to hooman.pet.name 'pet' hooman.pet}}
```

The router would be setup as:

```js
// you should make this one of the last routes
this.route('pet', { path: '/:pet_type/:pet_id' });
```

When we are using `link-to` there really isn't an issue as Ember will
just use the model passed in as the model. But we want a nicely
formatted URL. Ideally if we are passing in a `cat` pet we would
end up with the url: `/cats/2` and if we are passing in a `dog`
pet we'd get `/dogs/5` and both would be processed by the `pet`
route and template (of course we'd have to make sure they both respond
to the same properties).

To get this we can override the
[`serialize`](http://emberjs.com/api/classes/Ember.Route.html#method_serialize) function in our `pet`
route. `serialize` is used to parse information out of your model to
render the URL associated. It is simple enough to do what we want:

```js
import Ember from 'ember';

const {
  get,
  Route
} = Ember;

export default Route.extend({
  serialize(model) {
    return {
      pet_type: model.constructor.modelName,
      pet_id: get(model, 'id')
    };
  }
});
```

Now the `link-to` will render how we'd expect. Well, mostly. With this
we end up with singular route names: `/dog/5` instead of `/dogs/5` for
example. We need to pluralize.

Because we're using Ember Data the
[ember-inflector](https://github.com/stefanpenner/ember-inflector) library is pulled
in automatically. Let's use that:

```js
import Ember from 'ember';

const {
  get,
  Route,
  String: { pluralize }
} = Ember;

export default Route.extend({
  serialize(model) {
    return {
      pet_type: pluralize(model.constructor.modelName),
      pet_id: get(model, 'id')
    };
  }
});
```

Now we get `/dogs/5`. If you are using a different type that does not
pluralize nicely (for example `person` => `persons` instead of `people`)
then check out the [ember-inflector README for details on how to add the
pluralized types you
need](https://github.com/stefanpenner/ember-inflector).

This is great, except if someone visits the URL directly instead of
clicking on a link. Let's add support for that.

```js
import Ember from 'ember';

const {
  get,
  Route,
  String: { pluralize, singularize }
} = Ember;

export default Route.extend({
  model(params) {
    return this.store.find(singularize(params.pet_type), params.pet_id);
  },
  serialize(model) {
    return {
      pet_type: pluralize(model.constructor.modelName),
      pet_id: get(model, 'id')
    };
  }
});
```

There we go! Because the URL segment was pluralized we used
`singularize` to force the type back to what the `store` expects. I hope
this helps you.
