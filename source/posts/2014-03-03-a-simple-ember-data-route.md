---
layout: post
title: "A Simple Ember Data Route"
comments: true
author: Brian Cardarella
twitter: bcardarella
github: bcardarella
social: true
summary: "A basic pattern for routes with Ember Data content"
published: true
ember_start_version: '1.4'
tags: ember
---

When working with an Ember Data model it is easy to forget to properly
handle the teardown of that model. For example, if you are creating a
new model and the user hits the backbutton that model is still in the
local `store`. Or if a user edits a model and decides to click the
`Cancel` button or clicks a link that transitions out of this route
without saving the model. A basic approach can be as simple as:

```javascript
Ember.DSModelRoute = Ember.Route.extend({
  deactivate: function() {
    var model = this.get('controller.model');
    model.rollback();
    if (model.get('isNew')) {
      model.deleteRecord();
    }
  },
  actions: {
    willTransition: function(transition) {
      var model = this.get('controller.model');
      if (model.get('isDirty') && !confirm('You have unsaved changes. They will be lost if you continue!')) {
        transition.abort();
      }
    }
  }
});
```

Routes inherited from `Ember.DSModelRoute` will always clean up after themselves. If the user has unsaved changes and attempts to leave the current route 
the app will guard against the transition and allow the user to confirm with a notice that changes will be lost.
