---
layout: post
title: "Ember Best Practices: Actions Down, Data Up... wait what?"
social: true
author: Marin Abernethy
twitter: "pairinMarin"
github: maabernethy
published: true
tags: ember, javascript, best practices
---

Welcome back for to the fourth installment of DockYard's Ember Best Practices Blog Post Series! Last time Aaron Sikes explains why we can move away from the Ember `{{input}}` helper with angle-bracket components and improved actions. Aaron briefly discusses "Data down, actions up", the topic of this post. So if you want a bit of context, stick around here for a minute then head over to his [post](https://dockyard.com/blog/2015/10/05/ember-best-practices-using-native-input-elements) afterwards.


## Data Down, Actions Up

Two-way data binding is what originally attracted many to Ember.js. Data changes that affect the model are
immediately propagated to the corresponding template, and conversely, any changes made in the UI are 
promptly reflected in the underlying model. Magic! This conveniently removes unnecessary boilerplate code.

However, when employed in large scale and complex applications, two-way data binding can often become more of a
headache than a blessing. Have you struggled with where to mutate your data? Have you spent an excessive amount of time tracing the source of mutated data? You are not alone. The Ember core team in their quest for continuous growth and improvement, has decided that in Ember 2.X, one-way bindings will be the default. And the ability to opt in to two-way data binding will be provided. This new adopted data flow model will simplify communication between components and can be encapsulated in the phrase: "data down, actions up". 

That's all well and good, but what does that actually look like in the wild? 

## Enough jabbering and show us!

Let's build an app together. Our app will be a simple budgeting tool. Picture the money managing application,
[Mint](https://www.mint.com/), and more specifically an elementary version of its [budgeting feature](https://www.mint.com/how-mint-works/budgets).

```js
// application/index/route.js

import Ember from 'ember';

export default Ember.Route.extend({
  model () {
   return this.store.findAll('expense');
  },
  
  setupController(controller, model) {
    controller.set('expenses', model);
  }
});
```

Assume our server responds with a list of `expenses`, where each `expense` has a `category` and `amount`.
In our template we provide an input box for the user to tell us their `income`. Then we iterate over the `expenses`,
wrapping each `expense` in a component. And lastly, we display their `total` remaining money (`income - expenses`).

```hbs
{{! application/index/template.hbs }}

<h4>Income:</h4> 
{{input class="income-input" type="integer" value=income}}

<table class="expenses">
  <tbody>
    {{#each expenses as |expense|}}
      {{expense-summary expense=expense}}
    {{/each}}
  </tbody>
</table>

<h4>Total: {{total}}</h4>
```

```js
// application/index/controller.js
import Ember from 'ember';

export default Ember.Controller.extend({
  income:  0,
  total: Ember.computed('expenses', 'income', {
    get() {
      const amounts = this.get('expenses').mapBy('amount');
      const expenseTotal = amounts.reduce((previousValue, currentValue) => {
        return previousValue + currentValue;
      }, 0);
      
      return this.get('income') - expenseTotal;
    }
  })
```

In each row of our expenses table, we have an `expenseSummaryComponent` that displays the expense `category`,
provides an input box for the expense `amount`, and has a "Save" button.

```hbs
{{! expense-summary/template.hbs }}

<tr>
  <td>{{expense.category}}</td>
  <td>{{input type="integer" value=expense.amount}}</td>
  <td><button {{action 'amountChanged'}}>Save</button></td>
</tr>
```

In our `expense-summary` component we implement the `save` action.

```js
// expense-summary/component.js
import Ember from 'ember';

export default Ember.Component.extend({
  actions: {
    save() {
      const expense = this.get('expense');
      expense.save();
    }
  }
});
```

Yay! Done! However, we forgot something - we haven't applied our new mantra, "data down, actions up", to this code yet.The issue is that the `expenseSummaryComponent` is updating the data (`expense.amount`), but the data should solely belong to our `IndexController`. Not only did the `IndexController` give the `expenseSummaryComponent` the `expense` data, but it also uses the `expenses` data to calculate the `total`. Meaning, if the `IndexController` was out of sync and had stale `expense` data, it would be displaying the incorrect `total`. While that may not be a huge concern in this simple scenario, it can be really difficult to trace in more extensive and intricate applications.

### The Better Way

Instead we need to pass an action to our `expenseSummaryComponent`.

```hbs
{{! parent component: expense-table/template.hbs }}

<table class="expenses">
  <tbody>
    {{#each expense in expenses}}
    	{{expense-summary expense=expense amountChanged="update"}}
    {{/each}}
  </tbody>
</table>
```

The `expenseSummaryComponent` template looks the same as before. But this time, the action `amountChanged`, called
when the user clicks the "Save" button in the component, will look different. 

```js
// expense-summary/component.js
import Ember from 'ember';

export default Ember.Component.extend({
  actions: {
    amountChanged() {
      const expense = this.get(this, 'expense');
      this.sendAction('update', expense); 
    }
  }
});
```

The `update` action is now sent up to the parent Component or Controller, along with the `expense` as a parameter.

```js
// application/index/controller.js
import Ember from 'ember';

export default Ember.Controller.extend({
  ...
  
  actions: {
    update(expense) {
      expense.save();
    }
  }
```

Since `expense.save()` is now happening in the Controller, the server will respond with the updated
version of the `expense` (with the correct `amount`) and update the template automatically.

### The Angle-Bracket Way

In Ember, components (and solely components) are the way of the future! And the future is now, with the recent
release of [Ember v2.1.0](http://emberjs.com/blog/2015/08/16/ember-2-1-beta-released.html), routable components
and [`angle-bracket components`](https://github.com/emberjs/rfcs/pull/15) are live on Canary behind a feature flag.
Here is what that might look like for our budget form example.

```hbs
{{! expense-table/template.js}}

<table class="expenses">
  <tbody>
    {{#each expenses as |expense|}}
      <expense-summary expense=expense amountChanged={{action "update"}}>
    {{/each}}
  </tbody>
</table>
```

```js
// expense-summary/component.js

export default Ember.Component.extend({
  actions: {
    amountChanged() {
      this.attrs.update(this.get('expense'));
    }
  }
});
```

## Final Remarks

I won't dive anymore into that in this blog post. A little birdy told me that closure actions will be the subject of
a future Ember Best Practices Post. So look out for it! And remember to go back to Aaron's post on [using native input elements](https://dockyard.com/blog/2015/10/05/ember-best-practices-using-native-input-elements) if you haven't already.

I have put together an [Ember Twiddle](http://ember-twiddle.com/fc4760a5e5c475bbabc1) with the example
we worked through today. It also demonstrates how by following the "data down, actions up" best practice,
changes in the UI of one component can easily propagate and be reflected in other components. Check it out and feel
free to play around!
