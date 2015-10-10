---
layout: post
title: "Ember Macros for DRY and Testable Code"
comments: true
author: 'Lin Reid'
github: linstula
twitter: linstula
social: true
comments: true
published: true
tags: ember, testing, best practices
ember_start_version: '1.5'
---

### Intro
This post in going to explore the idea of writing your own Ember macros
as a strategy for DRYing up and creating more modular Ember code. 
As you'll see, besides the maintainability and flexibility benefits gained by DRYing
up and decoupling code, isolated code is significantly easier to test.
We'll be using a sample application to illustrate refactoring some code
into a macro.

### What is a Computed Property Macro?
A computed property macro can really be thought of as a function that returns the
definition of a computed property. Essentially, we are creating a function that will
define computed properties for us. They look something like this:

```javascript
// Defining a computed property macro
function greeting(dependentKey, greeting) {
  return Ember.computed(dependentKey, function() {
    return greeting + ', ' + dependentKey;
  });
}

// Consuming a computed property macro
var Greeter = Ember.Object.extend({
  user: null,
  englishGreeting: greeting('user', 'Hello'),
  spanishGreeting: greeting('user', 'Hola')
});

var concierge = Greeter.create({ user: 'Narwin' });
concierge.get('englishGreeting') // => 'Hello, Narwin'
concierge.get('spanishGreeting') // => 'Hola, Narwin'

concierge.set('user', 'Boomer');
concierge.get('englishGreeting') // => 'Hello, Boomer'
concierge.get('spanishGreeting') // => 'Hola, Boomer'
```

So, why not just use a standard computed property? Macros give us the
ability to take common chunks of functionality and share them throughout
our code, allowing us to avoid re-writing the logic every time we need
it. 

Ember provides us with a bunch of useful computed macros
right out of the box. If you're not familiar with them, you should
definitely [check them out](http://emberjs.com/api/#method_computed).

Now that we've covered our bases, lets move on to the sample app.

### Sample App
The goal of our sample application is to track financial transactions
and to provide an overview of income and expenses for a given time frame.
Our app has a `Month` model which has many `transactions`. A `Month` also
has `incomeTransactions` (transactions with positive amounts) and
`expenseTransactions` (transactions with negative amounts). Below are
tests and code for our `Month` and `Transaction` models.


`app/models/month.js`

```javascript
var hasMany = DS.hasMany;
var filter = Ember.computed.filter;

export default DS.Model.extend({
  transactions: hasMany('transaction'),

  incomeTransactions: filter('transactions', function(transaction) {
      // Grab all transactions with a positive amount.
      return transaction.get('amount') > 0;
    }
  ),

  expenseTransactions: filter('transactions', function(transaction) {
      // Grab all transactions with a negative amount.
      return transaction.get('amount') < 0;
    }
  )
});
```

`tests/unit/models/month-test.js`

```javascript
import { test, moduleForModel } from 'ember-qunit';

var store, month, transactions, tran1, tran2, tran3, tran4;

moduleForModel('month', 'Unit - Month Model', {
  needs: ['model:transaction'],

  setup: function(container) {
    store = container.lookup('store:main');

    month = this.subject({
      name: 'June'
    });

    Ember.run(function() {
      tran1 = store.createRecord('transaction', { amount: 100 });
      tran2 = store.createRecord('transaction', { amount: 200 });
      tran3 = store.createRecord('transaction', { amount: -300 });
      tran4 = store.createRecord('transaction', { amount: -400 });

      transactions = [tran1, tran2, tran3, tran4];

      month.get('transactions').addObjects(transactions);
    });
  }
});

test('incomeTransactions returns positive transactions', function() {
  expect(1);

  var results = month.get('incomeTransactions');

  deepEqual(results, [tran1, tran2]);
});

test('expenseTransactions returns negative transactions', function() {
  expect(1);

  var results = month.get('expenseTransactions');

  deepEqual(results, [tran3, tran4]);
});
```


`app/models/transaction.js`

```javascript
var attr = DS.attr;

export default DS.Model.extend({
  amount: attr('number')
});
```


The month controller will handle computing the `incomeTotal` and
`expenseTotal` for the month.

`app/controllers/month.js`

```javascript
var computed = Ember.computed;

export default Ember.ObjectController.extend({
  incomeTotal: computed('incomeTransactions.[]', function() {
    // Get the amount for each transaction in incomeTransactions.
    var amounts = this.get('incomeTransactions').mapBy('amount');

    // Sum the amounts
    return amounts.reduce(function(previousValue, currentValue) {
      return previousValue += currentValue;
    }, 0);
  }),

  expenseTotal: computed('expenseTransactions.[]', function() {
    // Get the amount for each transaction in expenseTransactions.
    var amounts = this.get('expenseTransactions').mapBy('amount');

    // Sum the amounts
    return amounts.reduce(function(previousValue, currentValue) {
      return previousValue += currentValue;
    }, 0);
  })
});
```

`tests/unit/controllers/month-test.js`

```javascript
import { test, moduleFor } from 'ember-qunit';

var set = Ember.set;

var monthController, incomeTransactions, expenseTransactions;

moduleFor('controller:month', 'Unit - Month Controller', {
  setup: function() {
    incomeTransactions = [
      { amount: 100 },
      { amount: 200 }
    ];

    expenseTransactions = [
      { amount: -300 },
      { amount: -400 }
    ];

    monthController = this.subject({
      incomeTransactions: incomeTransactions,
      expenseTransactions: expenseTransactions
    });
  }
});

test('incomeTotal returns the total of all incomeTransactions', function() {
  expect(1);

  var result = monthController.get('incomeTotal');

  equal(result, 300);
});

test('incomeTotal recomputes when an incomeTransaction is added', function() {
  expect(1);

  var newTransaction = { amount: 500 };

  monthController.get('incomeTransactions').addObject(newTransaction);

  var result = monthController.get('incomeTotal');

  equal(result, 800);
});

test('expenseTotal returns the total of all expenseTransactions', function() {
  expect(1);

  var result = monthController.get('expenseTotal');

  equal(result, -700);
});

test('expenseTotal recomputes when an expenseTransaction is added', function() {
  expect(1);

  var newTransaction = { amount: -600 };

  monthController.get('expenseTransactions').addObject(newTransaction);

  var result = monthController.get('expenseTotal');

  equal(result, -1300);
});
```


If your spidey senses are tingling, they should be. There is a lot of
duplication going on in above code. In fact, the only difference between `incomeTotal` and
`expenseTotal` is which set of transactions they are working with (incomeTransactions
or expenseTransactions). Similarly, the only difference between `incomeTransactions` and `expenseTransactions`
is whether the amount is a positive or negative number. Let's write a couple of macros to DRY up this code.


### Creating custom Ember Macros
Both `incomeTotal` and `expenseTotal` have almost exactly the same
logic. The goal of each is to take an array of objects and return the
sum of a specific property on each object. Let's create a `sumBy` macro
with the goal of being able to write something like: `sumBy('array', 'property')`.

`app/utils/sum-by.js`

```javascript
export default function(collection, property) {
  return Ember.reduceComputed(collection, {
    initialValue: 0.0,

    addedItem: function(accumulatedValue, item){
      return accumulatedValue + Ember.get(item, property);
    },

    removedItem: function(accumulatedValue, item){
      return accumulatedValue - Ember.get(item, property);
    }
  });
}
```

`tests/utils/sum-by.js`

```javascript
import { test } from 'ember-qunit';
import sumBy from '../../../utils/sum-by';

var set = Ember.set;

var bankAccount, transactions, tran1, tran2, tran3, tran4;

module('Unit - SumBy', {
  setup: function() {
    tran1 = { amount: 1 };
    tran2 = { amount: 2 };
    tran3 = { amount: 3 };
    tran4 = { amount: -4 };

    transactions = [tran1, tran2, tran3, tran4];

    bankAccount = Ember.Object.extend({
      transactions: transactions,
      totalAmount: sumBy('transactions', 'amount')
    }).create();
  }
});

test('returns the sum of property for all objects in collection', function() {
  expect(1);
  var actual = bankAccount.get('totalAmount');

  deepEqual(actual, 2);
});

test('recomputes when a new object is added to the collection', function() {
  expect(2);
  deepEqual(bankAccount.get('totalAmount'), 2, 'precondition');

  var newTrans = { amount: 10 };

  bankAccount.get('transactions').addObject(newTrans);

  var actual = bankAccount.get('totalAmount');

  deepEqual(actual, 12);
});
```


`incomeTransactions` and `expenseTransactions` could also use some
DRYing up. The only difference between the two is whether they are
filtering by positive of negative numbers. Let's write a `filterBySign`
macro with the goal of being able to write something like: 
`filterBySign('array', 'property', '+')`.

`app/utils/filter-by-sign.js`

```javascript
var get = Ember.get;
var filter = Ember.computed.filter;

export default function(collection, property, sign) {
  return filter(collection, function(object) {
    return (sign + 1) * get(object, property) > 0;
  });
}
```

`tests/unit/utils/filter-by-sign-test.js`

```javascript
import { test } from 'ember-qunit';
import filterBySign from '../../../utils/filter-by-sign';

var bankAccount, transactions, tran1, tran2, tran3, tran4;

module('Unit - filterBySign', {
  setup: function() {
    tran1 = { amount: 1 };
    tran2 = { amount: 2 };
    tran3 = { amount: -3 };
    tran4 = { amount: -4 };

    transactions = [tran1, tran2, tran3, tran4];

    bankAccount = Ember.Object.extend({
      transactions: transactions,
      positiveTransactions: filterBySign('transactions', 'amount', '+'),
      negativeTransactions: filterBySign('transactions', 'amount', '-')
    }).create();
  }
});

test("'+' returns all objects with positive property values", function() {
  expect(1);
  var actual = bankAccount.get('positiveTransactions');
  var expected = [tran1, tran2];

  deepEqual(actual, expected);
});

test("'-' returns all objects with negative property values", function() {
  expect(1);
  var actual = bankAccount.get('negativeTransactions');
  var expected = [tran3, tran4];

  deepEqual(actual, expected);
});

test('recomputes when a new object is added to the dependent array',
function() {
  expect(2);
  deepEqual(bankAccount.get('positiveTransactions'), [tran1, tran2]);

  var newTrans = { amount: 1000 };
  bankAccount.get('transactions').addObject(newTrans);

  var actual = bankAccount.get('positiveTransactions');
  var expected = [tran1, tran2, newTrans];

  deepEqual(actual, expected);
});
```

When reading through the tests for `filterBySign`, note how much easier the setup is compared
to our original tests for the same functionality on the `Month` model. Because
we're testing the code in isolation, we're able to use POJOs
and arrays to test our code. This allows us to avoid having to work
around the `Month` model's relationships, creating records with the
store and wrapping our setup code in an `Ember.run` to handle async
behavior. Much nicer!

###Refactoring the Month Model and Controller
We can now refactor our month model and controller to use our new
macros.

`app/model/month.js`

```javascript
import filterBySign from '../utils/filter-by-sign';

var hasMany = DS.hasMany;

export default DS.Model.extend({
  transactions: hasMany('transaction'),

  incomeTransactions: filterBySign('transactions', 'amount', '+'),
  expenseTransactions: filterBySign('transactions', 'amount', '-')
});
```

`app/controllers/month.js`

```javascript
import sumBy from '../utils/sum-by';

export default Ember.ObjectController.extend({
  incomeTotal: sumBy('incomeTransactions', 'amount'),
  expenseTotal: sumBy('expenseTransactions', 'amount')
});
```

The refactored model and controller are nice and concise while still
maintaining their readability. We can now delete our old unit tests on
our `Month` model and controller as they now overlap with our macro tests.
The net result is trimming down the code we have to maintain by about
half.

If you're thinking about writing a macro or just want to see what other macros
are out there, check out [ember-cpm](https://github.com/jamesarosen/ember-cpm). 
It's a library of non-core macros that you can plug in to you Ember app.
If you can't find what you're looking for there, take a shot at writing
your own macro and send in a pull request to share it with the
community!
