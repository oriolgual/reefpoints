---
layout: post
title: "Adding route specific body class tags in Ember"
comments: true
author: Brian Cardarella
twitter: bcardarella
github: bcardarella
legacy_category: ember
social: true
summary: "For design!"
published: true
ember_start_version: '0.9.8'
tags: javascript, design
---

Our [designer](http://twitter.com/cssboy) likes to use body class tags
depending upon the context of the app he is designing. We're currently
building an Ember app and this is how I got it working:

```javascript
Ember.Route.reopen({
  activate: function() {
    var cssClass = this.toCssClass();
    // you probably don't need the application class
    // to be added to the body
    if (cssClass != 'application') {
      Ember.$('body').addClass(cssClass);
    }
  },
  deactivate: function() {
    Ember.$('body').removeClass(this.toCssClass());
  },
  toCssClass: function() {
    return this.routeName.replace(/\./g, '-').dasherize();
  }
});
```
