---
layout: post
title: "Ember Best Practices: Computed Properties with Dynamic Dependent
Keys"
social: true
author: "Michael Dupuis"
twitter: michaeldupuisjr
github: michaeldupuisjr
summary: "Need to determine the dependent key for your computed
property at runtime?"
published: true
tags: ember, javascript
ember_start_version: 1.13
---

In Ember, computed properties allow you to declare functions as properties. More often than not, you're going to have a set of dependent keys which invoke a function when their values change:

```js
const Team = Ember.Object.extend({
  city: null,
  league: null,
  name: null,

  fullName: Ember.computed('city', 'name', {
    get() {
      return `${Ember.get(this, 'city')} ${Ember.get(this, 'name')}`;
    }
  })
});

const redSox = Team.create({
  city: 'Boston',
  league: 'American',
  name: 'Red Sox'
});

Ember.get(redSox, 'fullName'); // "Boston Red Sox"
```

In the example above, `fullName` is dependent on `city` and `name`, so
it watches those properties, and when either of their values change,
its `get` function is invoked, thereby returning the updated `fullName`
property for our beloved baseball team.

What if you wanted to write a computed property that didn't know what
keys it needed to monitor until runtime?

In our contrived examples below, our `model` is an array of
baseball teams which will be passed to a component.

```js
import Ember from 'ember';

const Team = Ember.Object.extend({
  city: null,
  league: null,
  name: null
});

export default Ember.Route.extend({
  model() {
    return {
      teams: [
        Team.create({ league: 'American', city: 'Boston', name: 'Red Sox' }),
        Team.create({ league: 'American', city: 'New York', name: 'Yankees' }),
        Team.create({ league: 'National', city: 'Los Angeles', name: 'Dodgers' }),
        Team.create({ league: 'National', city: 'San Francisco', name: 'Giants' })
      ]
    }
  }
});
```

In a component, we're going to separate our American League teams and our National
League teams.

```handlebars
{{league-teams leagueData=model}}
```

```js
// league-teams/component.js
import Ember from 'ember';

export default Ember.Component.extend({
  americanLeagueTeams: Ember.computed('leagueData.teams.@each.league', {
    get() {
      const teams = Ember.get(this, 'leagueData.teams');
      return teams.filterBy('league', 'American');
    }
  }),

  nationalLeagueTeams: Ember.computed('leagueData.teams.@each.league', {
    get() {
      const teams = Ember.get(this, 'leagueData.teams');
      return teams.filterBy('league', 'National');
    }
  })
});
```

We have two computed properties in our component. The first one pulls the
American League teams and the second pulls the National League teams.
The functions performing this work are virtually identical with the
exception of the value against which they are filtering (i.e.,
"American" and "National"). Let's DRY
this code up a bit:

```js
import Ember from 'ember';

function filterByLeague(value) {
  return Ember.computed('leagueData.teams.@each.league', {
    get() {
      const collection = Ember.get(this, 'leagueData.teams');
      return collection.filterBy('league', value);
    }
  });
}

export default Ember.Component.extend({
  americanLeagueTeams: filterByLeague('American'),
  nationalLeagueTeams: filterByLeague('National')
});

```

That refactor removes a bit of code duplication, but we can go further.
Rather than leaning on the static dependent key of
`leagueData.teams.@each.league`, we can make the `filterByLeague`
function more generic if we can just pass in the key we want to filter
on:

```js
 import Ember from 'ember';

 function filterCollectionByValue(collectionKey, propName, value) {
   return Ember.computed(`${collectionKey}.@each.${propName}`, {
     get() {
       const collection = Ember.get(this, collectionKey);
       return collection.filterBy(propName, value);
     }
   });
 }

 export default Ember.Component.extend({
   americanLeagueTeams: filterCollectionByValue('leagueData.teams', 'league', 'American'),
   nationalLeagueTeams: filterCollectionByValue('leagueData.teams', 'league', 'National')
 });
```

ES6 allows for string interpolation. This means that we can pass in the
key we want to filter by and also watch it as the dependent key. If we
need to filter a collection based off of keys other than `league` in the
future, we
can use this generic `filterCollectionByValue()` util rather than creating
a unique `filterByX()` function for each key.

Another dimension to the idea of dynamic dependent keys is the ability to watch an arbitrary number of them. The macro computed property `getPropertiesByKeys()` does just that. This function allows you to provide an
arbitrary number of dependent keys and return their values:

```js
export function getPropertiesByKeys(...dependentKeys) {
  const computedFunc = Ember.computed({
    get() {
      return Ember.getProperties(this, dependentKeys);
    }
  });

  return computedFunc.property.apply(computedFunc, dependentKeys);
}
```

As you can see, this macro is more or less relying on Ember's
[`getProperties()`](http://emberjs.com/api/classes/Ember.Object.html#method_getProperties) method, but it allows you to specify the dependent keys at runtime.

Leveraging dynamic dependent keys in computed properties opens the door
to greater refactoring. These helper functions which return a computed
property can be moved into a computed property macros util and imported
as needed throughout your project.

Better yet, let my esteemed colleague, Lauren Tan, do the work for you! Her
[ember-macaroni](https://github.com/poteto/ember-macaroni) library wraps
up many of the macros we use at DockYard in a convenient [Ember
addon](https://www.npmjs.com/package/ember-macaroni).
