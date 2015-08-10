---
layout: post
title: 'Applying the Adapter Pattern for Analytics'
twitter: 'sugarpirate_'
github: 'poteto'
author: 'Lauren Tan'
tags: ember, addon, javascript
social: true
comments: true
published: true
summary: "Send data to multiple analytics integrations without re-implementing new API."
---

At DockYard, most (if not all) Ember apps we build for our clients require analytics in some form or other. For many of these apps, simply including the Google Analytics tracking script is sufficient. However, we're noticing an increased interest in other analytics services such as Mixpanel or Kissmetrics for the more data minded clients.

Including multiple services (typically we see about 3–5 different analytics in use) with different APIs leads to a lot of code duplication, which is less than ideal, and is generally a maintenance nightmare. I don't know about you, but deleting repetitive code is one of my favorite things to do — so [Michael](https://twitter.com/michaeldupuisjr) and I set out to build an Ember addon that would apply the adapter pattern to analytics.

In this post, we'll explore what the adapter pattern gives us, and demonstrate how to implement it in an easily extensible Ember addon so we can use one API to orchestrate multiple analytics services.

## Introducing the ember-metrics addon

To install the addon:

```sh
$ ember install ember-metrics
```

You can also find the [source on GitHub](https://github.com/poteto/ember-metrics).

The ember-metrics addon adds a simple metrics service and customized `LinkComponent` to your app that makes it simple to send data to multiple analytics services without having to implement a new API each time.

Using this addon, you can easily use bundled adapters for various analytics services, and one API to track events, page views, and more. When you decide to add another analytics service to your stack, all you need to do is add it to your configuration, and that's it.

With this addon, we wanted to make it super simple to write your own adapters for other analytics services too, so we set out to make it extensible and easily tested.

## What is the Adapter Pattern?

![I heard you like adapters](http://i.imgur.com/VpAAHrw.jpg)

In a broad sense, the adapter pattern is about adapting between class and objects. Like its real world counterpart, the adapter is used as an interface, or bridge, between two objects.

In the case of analytics, this is an excellent pattern for us to implement, because these services all have different APIs, but very similar intent. For example, to send an event to Google Analytics, you would use the analytics.js library like so:

```js
/** 
 * Where:
 * button is the category
 * click is the action
 * nav buttons is the label
 * 4 is the value
*/
ga('send', 'event', 'button', 'click', 'nav buttons', 4);
```

While in Mixpanel, you would track the same event like this:

```js
mixpanel.track('Clicked Nav Button', { value: 4 });
```

And with Kissmetrics:

```js
_kmq.push(['record', 'Clicked Nav Button', { value: 4 }]);
```

As you can probably tell, this gets repetitive really quickly, and becomes hard to maintain when your boss or client wants to update something as simple as the event name across these services.

## Applying the Adapter Pattern

![Diagram from https://sourcemaking.com/design_patterns/adapter](http://i.imgur.com/azNt3ri.png)

We generally have a few players in the adapter pattern: the client, the adapter (or wrapper), and the adaptee.

For ember-metrics, the client is our `Ember.Service`, the adapter is the adapter created for each analytics service, and the adaptee is the analytics library's API.

Each analytics service has its own adapter that implements a standard contract to impedance match the analytics library's API to the `Ember.Service` that is responsible for conducting all of the analytics in unison.

## Using ember-metrics

The addon is first setup by configuring it in `config/environment`, then injected into any Object registered in the container that you wish to track.

```js
module.exports = function(environment) {
  var ENV = {
    metricsAdapters: [
      { name: 'GoogleAnalytics', config: { id: 'UA-XXXX-Y' } },
      { name: 'Mixpanel', config: { token: 'xxx' } }
    ]
  }
}
```

Then, you can call a `trackPage` event across all your analytics services like so, using the `metrics` service:

```js
import Ember from 'ember';

export default Ember.Route.extend({
  metrics: Ember.inject.service(),

  activate() {
    this._trackPage();
  },

  _trackPage() {
    Ember.run.scheduleOnce('afterRender', this, () => {
      const page = document.location.href;
      const title = this.routeName;

      get(this, 'metrics').trackPage({ page, title });
    });
  }
});
```

If you wish to only call a single service, just specify its name as the first argument:

```js
// only invokes the `trackPage` method on the `GoogleAnalyticsAdapter`
metrics.trackPage('GoogleAnalytics', { title: 'My Awesome App' });
```

This is clearly a much cleaner implementation, as we can now use one API to invoke across all services we want to use in our app.

## Implementing the Adapter Pattern in ember-metrics
The service `metrics` is the heart of the addon, and is responsible for orchestrating event tracking across all analytics that have been activated.

### Setting up addon configuration
A simple pattern for passing configuration from the consuming app's `config/environment` to the addon is through an initializer:

```js
import config from '../config/environment';

export function initialize(_container, application) {
  const { metricsAdapters = {} } = config;

  application.register('config:metrics', metricsAdapters, { instantiate: false });
  application.inject('service:metrics', 'metricsAdapters', 'config:metrics');
}

export default {
  name: 'metrics',
  initialize
};
```

This lets us access the configuration POJO from within the metrics service by retrieving the `metricsAdapter` property when the service is created.

```js
import Ember from 'ember';

export default Ember.Service.extend({
  _adapters: {},

  init() {
    const adapters = Ember.getWithDefault(this, 'metricsAdapters', Ember.A([]));
    this._super(...arguments);
    this.activateAdapters(adapters);
  },

  activateAdapters(adapterOptions = []) {
    const cachedAdapters = Ember.get(this, '_adapters');
    const activatedAdapters = {};

    adapterOptions.forEach((adapterOption) => {
      const { name } = adapterOption;
      let adapter;

      if (cachedAdapters[name]) {
        warn(`[ember-metrics] Metrics adapter ${name} has already been activated.`);
        adapter = cachedAdapters[name];
      } else {
        adapter = this._activateAdapter(adapterOption);
      }

      Ember.set(activatedAdapters, name, adapter);
    });

    return Ember.set(this, '_adapters', activatedAdapters);
  }
});
```

With the retrieved configuration, we then call the service's `activateAdapters` method in order to retrieve the adapter(s) from the addon or locally, then caching them in the service so they can be looked up later easily.

Activating an adapter simply calls `create` on the looked up adapter (which inherits from `Ember.Object`) and passes along any analytics specific configuration such as API keys.

```js
_activateAdapter(adapterOption = {}) {
  const metrics = this;
  const { name, config } = adapterOption;

  const Adapter = this._lookupAdapter(name);
  assert(`[ember-metrics] Could not find metrics adapter ${name}.`, Adapter);

  return Adapter.create({ metrics, config });
}
```

Because we've also implemented caching, we can safely call `activateAdapters` without having to re-instantiate already activated adapters, which allows us to defer the initialization of these analytics if (for example) we need to dynamically retrieve a property from one of our models:

```js
import Ember from 'ember';

export default Ember.Route.extend({
  metrics: Ember.inject.service(),
  afterModel(model) {
    const metrics = Ember.get(this, 'metrics');
    const id = Ember.get(model, 'googleAnalyticsKey');

    metrics.activateAdapters([
      { name: 'GoogleAnalytics', config: { id } }
    ]);
  }
});
```

### Leveraging the container and resolver
Then, leveraging the Ember container and conventions around the [ember-resolver](https://github.com/ember-cli/ember-resolver), we can lookup adapters from the addon first, and then fallback to locally created adapters.

```js
_lookupAdapter(adapterName = '') {
  const container = get(this, 'container');

  if (isNone(container)) {
    return;
  }

  const dasherizedAdapterName = dasherize(adapterName);
  const availableAdapter = container.lookupFactory(`ember-metrics@metrics-adapter:${dasherizedAdapterName}`);
  const localAdapter = container.lookupFactory(`metrics-adapter:${dasherizedAdapterName}`);
  const adapter = availableAdapter ? availableAdapter : localAdapter;

  return adapter;
}
```

### Invoking adapter methods from the service
Now that our service can access both local and addon adapters, we can invoke methods across activated adapters like so:

```js
identify(...args) {
  this.invoke('identify', ...args);
},

alias(...args) {
  this.invoke('alias', ...args);
},

trackEvent(...args) {
  this.invoke('trackEvent', ...args);
},

trackPage(...args) {
  this.invoke('trackPage', ...args);
},

invoke(methodName, ...args) {
  const adaptersObj = get(this, '_adapters');
  const adapterNames = Object.keys(adaptersObj);

  const adapters = adapterNames.map((adapterName) => {
    return get(adaptersObj, adapterName);
  });

  if (args.length > 1) {
    let [ adapterName, options ] = args;
    const adapter = get(adaptersObj, adapterName);

    adapter[methodName](options);
  } else {
    adapters.forEach((adapter) => {
      adapter[methodName](...args);
    });
  }
}
```

## Creating Adapters for the Addon
With the service implemented, we can now create a [base adapter class](https://github.com/poteto/ember-metrics/blob/0.1.2/addon/metrics-adapters/base.js) that all adapters extend from. This is mainly so we can assert that the adapter's `init` and `willDestroy` hooks are implemented, and to give it a nicer output in the console through overriding the `toString` function.

If you're not already familiar with the Ember Object model, the `init` method is called whenever an `Ember.Object` is instantiated through `Ember.Object.create()`.

We can thus rely on this knowledge that `init` will always be called on object instantiation to pass in configuration to the analytics, and to call its setup. Typically, an analytics service will create a script tag through JavaScript, and asynchronously load its library from some CDN.

For example, here's the [Google Analytics adapter](https://github.com/poteto/ember-metrics/blob/0.1.2/addon%2Fmetrics-adapters%2Fgoogle-analytics.js) that's bundled with the addon.

### Enhancing the developer experience with blueprints
One of my favorite parts of ember-cli are its generators. Using blueprints, we can easily extend the cli commands to generate new metrics adapters using:

```sh
$ ember generate metrics-adapter foo-bar
```

This creates `app/metrics-adapters/foo-bar.js` and a unit test at `tests/unit/metrics-adapters/foo-bar-test.js`. You can take a closer look at these blueprints [here](https://github.com/poteto/ember-metrics/tree/0.1.2/blueprints).

With these conventions in place, it's now trivial for consuming app developers to add new adapters to work alongside bundled adapters. And when they feel that an adapter they've built is ready to be shared with the community, they only need open a pull request to have that adapter included in the addon.

At some point in the future, it would make sense for each adapter to have its own repo and npm module, but to keep things simple, we've placed them within the addon.

Now we can easily send data to multiple analytics integrations through one API, DRYing up our code and making it more maintainable.

*This post also appears on [Medium in longform](https://medium.com/the-ember-way/applying-the-adapter-pattern-for-analytics-in-ember-js-apps-29448cbcedf3).*
