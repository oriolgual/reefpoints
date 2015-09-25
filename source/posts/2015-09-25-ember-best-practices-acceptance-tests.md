---
layout: post
title: "Ember Best Practices: DRYer and less fragile Acceptance Tests"
twitter: linstula
github: linstula
author: "Lin Reid"
tags: ember, javascript, best practices
social: true
comments: true
published: true
---

This is the second in a series of posts designed to share our experiences around developing Ember.js apps and the best practices that we've found while doing so.
If you missed the first post from Estelle about [not leaking state into factories](https://dockyard.com/blog/2015/09/18/ember-best-practices-avoid-leaking-state-into-factories) you should check it out!

### Intro
In this post, I'm going to be talking about writing less fragile acceptance tests that are easier to maintain.
Renaming CSS classes or refactoring the HTML structure of an application can cause our acceptance tests to fail, even if the end-user experience is the same.
When this happens, it's not uncommon to spend a disproportionate amount of time fixing broken tests rather than refactoring code.
If that sounds familiar, I've got a few approaches that you can use to create less fragile acceptance tests.
And more than that, when they do break, you can fix your test logic in one place rather than in every test that's failing.

## Minimize coupling tests to presentation
The first approach we’re going to talk about is decoupling your acceptance tests from the HTML structure and CSS of your application.
If your tests are breaking due to semantic HTML or class name changes but the end experience to the user is nearly exactly the same, this should be a red flag that your tests are too closely coupled to the HTML and CSS of your application.
Our acceptance tests should be from the perspective of a user interacting with the application.
A user doesn’t care about whether the element they are clicking on is a `<button>` or a `<span>` or whether we use a class name of `post` or `blog-post`.
They care that they can read a blog post, comment on it, and like it.

However, we can’t perfectly decouple our tests from presentation, as we still need to be able to find the elements that we need to interact with and make assertions against.
One approach to minimizing the coupling is to add a [data attribute](https://developer.mozilla.org/en-US/docs/Web/Guide/HTML/Using_data_attributes) to elements that we want to target during our tests.
Data attributes are attributes that are prefixed with `data-` and are intended to store meta data on elements:

```hbs
<div data-foo="some arbitrary data" data-bar="123"></div>
```

### Example test using data attributes
We can use these data attributes to identify elements that will be interacted with in our tests:

```hbs
<div class="post-likes">
  <span class="likes-count" data-test-selector="post-likes-count">{{likesCount}}</span>
  <button class="btn like" {{action "likePost"}} data-test-selector="post-like-button">Like</button>
</div>
```

```js
test('a user can like a post', function(assert) {
  assert.expect(2);

  visit('posts/1');

  andThen(function() {
    const likesCount = find('[data-test-selector="post-likes-count"]');
    assert.equal(likesCount.text(), 0, 'precondition - likes count starts at 0');
  });

  click('[data-test-selector="post-like-button"]');

  andThen(function() {
    const likesCount = find('[data-test-selector="post-likes-count"]');
    assert.equal(likesCount.text(), 1, 'clicking the like post button increments the likes count');
  });
});
```

Now, if we want to refactor our like button so it contains the likes count and change around some class names...

```hbs
<button class="btn like-post" {{action "likePost"}} data-test-selector="post-like-button">
  <span class="count" data-test-selector="post-likes-count">{{likesCount}}</span> Likes
</button>
```

Our test still passes without having to update our test logic because we're not targeting elements based on their class names or their relation to other elements on the page.
Success!

## Page Object Pattern
The next approach we're going to talk about is using the Page Object pattern to DRY out our test logic.
The goal of a Page Object is to represent an area of your UI that gets interacted with during tests.
Page Objects are responsible for abstracting away the details of how to target and interact with elements in the DOM and providing an API that can be used in tests for page interactions.
The name Page Object can be a bit misleading.
Most "pages" have a bit too much going on for them to be encapsulated into one object.
Generally, I’ve found that it makes more sense to model Page Objects after logical chunks of the UI.
You might have a Page Object representing your nav-bar, side-bar, or a group of components that compose a logical section of the UI.
For example, you might have a Page Object that is responsible for providing an API for targeting elements of an individual post:

```js
// tests/page-objects/post-show.js

// PageObject implementation using es6 Classes
import BasePageObject from './base'; // A base class for all page objects to extend from

export default class PostShowPageObject extends BasePageObject {
  constructor(assert) {
    this.assert = assert;
  }

  // interactions
  readPostId(id) {
    visit(`posts/${id}`);

    return this;
  }

  clickLikeButton() {
    click('[data-test-selector="post-like-button"]');

    return this;
  }

  // assertions
  assertLikesCount(count, message) {
    andThen(() => {
      const likesCount = find('[data-test-selector="post-likes-count"]');
      message = message || `likes count is: ${count}`;
      this.assert.equal(likesCount.text(), count, message);
    });

    return this;
  }
}
```

Here's what the exact same acceptance test would look like using our new Page Object:

```js
import PostShowPageObject from '../page-objects/post-show';

// other test code

test('a user can like a post', function(assert) {
  assert.expect(2);

  new PostShowPageObject(assert)
    .readPostId(1)
    .assertLikesCount(0, 'precondition - likes count starts at 0')
    .clickLikeButton()
    .assertLikesCount(1, 'clicking the like post button increments the likes count');
});
```

The real benefit here is that if you need to change how you target elements, you only have to fix it in one place rather than every test that interacts with that element.
Besides the maintainability of the test logic, it makes for super clean and readable tests! One thing to note is that there is some disagreement about
whether assertions should be a part of the API of a Page Object. Some people feel that a Page Object should strictly provide an API for page interactions.
Others feel that we tend to assert around a certain set of elements in our tests and DRYing up assertion logic by including assertions in the Page Object makes sense.
In my experience, I've found that including assertion helpers in my Page Objects has saved me a ton of time when adding new tests and maintaining old tests.

### Additional Resources
Mike North gave a great talk at [Wicked Good Ember](http://wickedgoodember.com/) last year about using Page Objects and data attributes for acceptance testing. I definitely recommend [checking it out](http://confreaks.tv/videos/wickedgoodember2015-compose-all-the-things).

### ember-page-object
If you're sold on the idea of using Page Objects and data attributes to target elements in acceptance tests,
[Lauren](https://twitter.com/sugarpirate_) and I created an addon called [ember-page-object](https://github.com/linstula/ember-page-object) that provides a base PageObject
class you can extend from to help get you started! Enjoy!
