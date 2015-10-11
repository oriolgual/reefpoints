---
layout: post
title: "A clean pattern for modal dialogs"
comments: true
author: Dan McClain
twitter: "_danmcclain"
googleplus: 102648938707671188640
github: danmcclain
social: true
summary: "The project you are working on has a number of modal dialogs, and the component helper can help"
published: true
tags: ember, components
ember_start_version: '1.12'
---

Recently, I was working on a project which had a number of different modals. I
discovered a really clean pattern for implementing modals via actions and
[`ember-modal-dialog`](https://github.com/yapplabs/ember-modal-dialog).

We implemented each of the different modals as separate components, and
rendered `ember-modal-dialog` in the `application` template the following
way:

```hbs
{{#if isModalVisible}}
  {{#modal-dialog}}
    {{component modalDialogName modalContext=modalContext closeAction="closeModal"}}
  {{/modal-dialog}}
{{/if}}
```

The component helper allows us to dynamically choose which modal we'd like to
see. We call the modal via the following action in the application route;

```js
const { setProperties, set } = Ember;

actions: {
  showModal(modalDialogName, modalContext) {
    const applicationController = this.controller;

    setProperties(applicationController, {
      modalDialogName,
      modalContext,
      isModalVisible: true
    });
  },

  closeModal() {
    const applicationController = this.controller;

    set(applicationController, 'isModalVisible', false);
  }
}
```

We invoke the modal via a normal action call:

```hbs
<button {{action "showModal" "my-component-name" contextForModal}}>Show the modal!</button>
```

The `modalContext` could be as simple as a string, or as complex as an
Ember-Data model. It gets passed to the component as the `modalContext`
attribute, so you'll need to remember to retrieve your properties from within
there if you are trying to do something a bit more complex.

The component helper is really what enables this pattern, otherwise you'd need
to either have a series of `if`s to display the correct modal. I may extract
this pattern into a separate addon, as I see it as one I'll reuse frequently
whenever we have multiple modal dialogs.
