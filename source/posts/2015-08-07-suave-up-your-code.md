---
layout: post
title: "Suave Up Your Code"
social: true
author: "Estelle DeBlois"
twitter: edeblois
github: brzpegasus
published: true
tags: ember, javascript, addon
---

> /swäv/
> "Smooth in texture, performance, or style"

You may have heard of this thing called [`ember-suave`](https://github.com/dockyard/ember-suave). It's a handy Ember CLI addon that [Robert Jackson](https://twitter.com/rwjblue) and I put together a few months ago to enforce code style consistency across teams and projects.

`ember-suave` uses [JSCS](http://jscs.info/) to ensure that your code conforms to a set of code style rules, and fails your tests if it doesn't.

Unlike [JSHint](http://jshint.com/), which aims to detect errors and potential problems in your JavaScript code, JSCS is a code style linter. In other words, it is the tool you need to make sure all those hearty debates on tabs vs. spaces don't go to waste, and that whatever style guide you managed to settle on within your team can be enforced and maintained.

![code quality](http://imgs.xkcd.com/comics/code_quality.png)

## The first rule of `ember-suave` is to install `ember-suave`

With JSCS, you control which rules to enable within a project by specifying the rule names and options in a `.jscsrc` file, which may look something like this:

```json
{
  "esnext": true,
  "disallowSpacesInsideParentheses": true,
  "disallowTrailingComma": true,
  "requireBlocksOnNewline": true,
  "validateIndentation": 2
}
```

Assuming you're adhering to a single style guide for all your projects, the configuration would be the same everywhere. `ember-suave` exists so you don't have to recreate and maintain that file in every project. The addon comes bundled with a default configuration file that's nicely tucked away within the addon itself so you don't have to muck with it.

Using the addon consists simply of running `ember install ember-suave`, then monitor your console for error messages during development.

`ember-suave` also creates a test for each file it finds in your project, so that you can enforce the code style rules as part of your continuous integration flow, and fail any builds that don't comply.

## You don't rule `ember-suave`. `ember-suave` rules you.

Actually, that's not quite true. The addon was made to be quite configurable.

You can use it as is, or you can tweak which rules to enable or disable. To configure `ember-suave`, simply create a `.jscsrc` file at the root of your project, listing just those rules that you want to modify. The addon will take care of merging your custom configuration with its own. For example, the following `.jscsrc` file would set a different indentation style from the default of 2 spaces. It would also disable the `requireSpaceBetweenArguments` rule and instruct JSCS to ignore all the files in the `fixtures` folder:

```json
{
  "validateIndentation": 4,
  "requireSpaceBetweenArguments": null,
  "excludeFiles": ["fixtures/**"]
}
```

## Need more suaveness?

If you have a particular code style need but no  rule exists in JSCS yet, you can easily roll your own. In fact, `ember-suave` ships with a few [custom rules](https://github.com/dockyard/ember-suave/tree/master/lib/rules) already. Let's take a look at the rule that disallows the use of `var`, preferring `const` and `let` instead:

```js
// lib/rules/disallow-var.js
var assert = require('assert');

module.exports = function() {};

module.exports.prototype = {
  configure: function(option) {
    assert(option === true, this.getOptionName() + ' requires a true value');
  },

  getOptionName: function() {
    return 'disallowVar';
  },

  check: function(file, errors) {
    file.iterateNodesByType('VariableDeclaration', function(node) {
      node.declarations.forEach(function(declaration) {
        if (declaration.parentNode.kind === 'var') {
          errors.add('Variable declarations should use `let` or `const` not `var`', node.loc.start);
        }
      });
    });
  }
};
```

A rule will always have these three methods: `configure`, `getOptionName`, and `check`.

* `getOptionName` is self-explanatory.

* `configure` is where you assert that a rule has been configured properly in a given `.jscsrc` file. For example, this would not pass the assert, since the value has to be `true`:

```json
{
  "disallowVar": "Feeling suave today!"
}
```

* `check` is where all the magic happens. Any given file would first get parsed by JSCS into an AST (Abstract Syntax Tree) before you can analyze its content. You can use the `file` object that is passed into the `check` function to iterate over specific nodes of the tree. For this custom rule, we are looking for any variables that were declared using `var`. If such a declaration is found, we add to the errors object, passing in an error message and the position of the offending code. This is what you would see in the console if you tried using `var`:

```
disallowVar: Variable declarations should use `let` or `const` not `var` at router.js :
     2 |import config from './config/environment';
     3 |
     4 |var Router = Ember.Router.extend({
--------^
     5 |  location: config.locationType
     6 |});
```

Confused about the node types and what to look for? It's actually not very complicated. You can navigate over to [Esprima](http://esprima.org/demo/parse.html), the parser used by JSCS, enter a code snippet into the [Online Parsing Tool](http://esprima.org/demo/parse.html), and see what the corresponding tree looks like.

For instance, `var color = 'blue';` will generate the following syntax tree:

```json
{
  "type": "Program",
  "body": [
    {
      "type": "VariableDeclaration",
      "declarations": [
        {
          "type": "VariableDeclarator",
          "id": {
            "type": "Identifier",
            "name": "color"
          },
          "init": {
            "type": "Literal",
            "value": "blue",
            "raw": "'blue'"
          }
        }
      ],
      "kind": "var"
    }
  ]
}
```

Now you can see why we were checking for nodes of type `VariableDeclaration`, and why we checked whether they were declared with `var` using `declaration.parentNode.kind === 'var'`.

You can also refer to the many [rules](https://github.com/jscs-dev/node-jscs/tree/master/lib/rules) that already exist in JSCS as you write your own.

## Conclusion

`ember-suave` started as an internal need at DockYard to enforce our [style guide](https://github.com/dockyard/styleguides/blob/master/javascript.md) in a painless, automatable way.

That said, the addon was built such that anyone can take advantage of the tool. If you start a new Ember CLI project, I recommend you check it out. And if you're thinking of dropping it into an existing project, but fear that the sheer amount of potential error messages would be too time-consuming to address all at once, you can always start by disabling all the rules, then re-enable them one rule at a time. Or you could exclude specific folders too; whatever helps bring more suaveness to your code.
