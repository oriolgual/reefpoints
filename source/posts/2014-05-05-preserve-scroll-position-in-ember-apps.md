---
layout: post
title: "Preserve scrolling position in Ember Apps"
comments: true
author: 'Brian Cardarella'
github: bcardarella
twitter: bcardarella
social: true
summary: A simple mixin for your views
published: true
tags: ember
ember_start_version: '1.5'
---

If you have a long list of items on a page and a user follows a link
then goes back to that list, Ember will re-render the list and the user
loses their place. This can be annoying if there is a very long list of
items and the user is expected to be switching back and forth between
the list and the item.

We can preserve the position by taking advantage of `didInsertElement`
on the list's view.

<a class="jsbin-embed"
href="http://emberjs.jsbin.com/nevaxipe/2/embed?output">Ember Starter
Kit</a><script src="http://static.jsbin.com/js/embed.js"></script>

**Note: there seems to be a bug with the latest stable in Chrome where
the position is never reset if you hit the backbutton. In reality it is
but the position doesn't render until you scroll. Canary seems OK as do
other browsers**

In the above example you can scroll down, click on an item, then head
back to the list and be in your original position. This is all done with
the following mixin:

```javascript
var ScrollableMixin = Ember.Mixin.create({
  scrollingTimeout: 100,
  bindScrolling: function() {
    var self = this,
    onScroll = function() {
      Ember.run.debounce(self, self.runScrolled, self.scrollingTimeout);
    };

    Ember.$(document).on('touchmove.scrollable', onScroll);
    Ember.$(window).on('scroll.scrollable', onScroll);
  }.on('didInsertElement'),

  unbindScrolling: function() {
    Ember.$(window).off('.scrollable');
    Ember.$(document).off('.scrollable');
  }.on('willDestroyElement'),

  preservePos: function() {
    Ember.$(window).scrollTop(this.getWithDefault('controller.currentPos', 0));
  }.on('didInsertElement'),

  runScrolled: function() {
    var position = Ember.$(document).height() - Ember.$(window).scrollTop();
    var viewportHeight = document.documentElement.clientHeight;
    this.set('controller.currentPos', Ember.$(window).scrollTop());
  }
});
```

You then mix it into your list's view:

```javascript
ThingsView = Ember.View.extend(ScrollableMixin);
```

Enjoy!
