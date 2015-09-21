---
layout: post
title: 'Rubyists Guide to Ember.js Dependencies'
twitter: 'michaeldupuisjr'
github: 'michaeldupuisjr'
author: 'Michael Dupuis'
tags: ruby, ember
social: true
summary: "A dependency management primer for Rubysist living in a Gemfile-less, Ember.js
world."
comments: true
published: true
---

At DockYard, we have a lot of Ruby on Rails experts who have adopted Ember on the frontend. One of the early hurdles a Ruby developer faces when working on an Ember.js application is dependency management. A popular mechanism for managing a Ruby application’s dependencies is the [Gemfile](http://bundler.io/gemfile.html) provided by [Bundler](http://bundler.io/ ). Including a library is as easy as declaring it in the Gemfile and running `bundle install`:

```ruby
# Gemfile
source 'https://rubygems.org'
gem 'rails', '~> 4.2.0'
```

For better or worse, there is no dominant, single package manager in JavaScript. Ember applications, and more specifically, those running [Ember-CLI](http://www.ember-cli.com/), rely on two package managers: [Bower](http://bower.io/) for client-side libraries and [npm](https://www.npmjs.com/) for server-side libraries.

In this post, I'll provide a basic dependency management primer for
those moving from Ruby to JavaScript.

## npm
Ember-CLI uses npm to manage internal dependencies. npm resembles RubyGems, in so far as it allows you to install and manage third-party libraries, which in this case, are Node.js programs.

### package.json
Libraries for npm are referred to as “packages.” Each package has a `package.json` file which lists the dependencies of the library itself. In this regard, the `package.json` is analogous to a RubyGem’s `gemspec` file.

### .npmrc
You can configure how node packages get installed via the
[.npmrc file](https://docs.npmjs.com/files/npmrc). You may have one
globally, per user (`~/.npmrc`), or per project.

### Installing dependencies
To install an npm package, run `npm install [package-name]` from the
command line.

This will either install the library and it's dependencies
into your current working directory or in one of its parent directories. Here's how it works: if there is a `node_modules/` or `package.json` in any directory above the current working directory, packages will be installed into that directory. Otherwise, calling `npm install [package-name]` creates a `node_modules/` directory in your current working directory and installs the packages there.

This is a slightly different mental model for Rubyists who are not used to installing gems on a per project basis; gems are generally installed into version-specific Ruby directories with the more popular version managers like [rbenv](https://github.com/sstephenson/rbenv) or [RVM](https://rvm.io/).

It’s also possible to install packages globally using the `--global` flag when installing. This installs the package in your `usr/local/lib/` directory by default. These packages typically contain executable files and are used via the command line (such as Ember-CLI).

Your dependencies will likely have dependencies. These get installed within a `node_modules/` directory in the given package. It's a little strange the first time you navigate into a `node_modules/package-name/` only to find another `node_modules/` directory, but that's what that is. You’ll notice a `node_modules/` directory for dependencies of global packages as well if you look in the `usr/local/lib/` directory where global packages live.

One last thing to note regarding npm installations: npm caches the
libraries you pull down to prevent you from having to download
libraries that are already on your system. You'll find that cache:
`~/.npm/`.

## Bower
While you'll use npm to manage your server-side Node.js dependencies, you’ll use Bower for managing front-end assets, such as JavaScript, HTML, CSS, image, and font files.

### .bowerrc
Bower itself is an npm package. Its libraries are referred to as “components” and the end user can configure their installations via a `.bowerrc` file. This file specifies where dependent components will be installed, the URL where the component will be registered (its registry), and the JSON file used to define the component (`bower.json` by default) among other things.

### bower.json
The [`bower.json`](http://bower.io/docs/creating-packages/#bowerjson) file resembles the [gemspec](http://guides.rubygems.org/specification-reference/) file you find in Ruby gems. It contains the library metadata, such as the name, version, dependencies, and development dependencies for the library.

As we mentioned, components can be searched for via registries. The registry matches the name of a component with the endpoint at which it’s hosted. [Bower.io/search](http://bower.io/search/) closely resembles [rubygems.org](https://rubygems.org/gems) in this way.

### Installing dependencies
When you install a Bower component via `bower install [component_name]`, the repository will be cached locally to expedite any future installations of the component. In case you’re curious, the bower cache location is: `~/.cache/bower/`.

Unlike npm, Bower components are installed "flat" as opposed to in a hierarchical manner; all of your project's components (and their dependencies) will be installed into `bower_components/` directory, by default. For example, if one of your components is dependent on the `underscore.js` library, both will sit side-by-side in the `bower_components/` directory (remember, with npm, dependencies of dependencies are continually nested in their parent's directory within a `node_modules/` directory).

## Conclusion
Here's a quick wrap-up of the analogous files between Ruby and the JS
package managers we discussed:

| Description  | Ruby | JS (npm, server-side) | JS (Bower, client-side) |
| ---- | ---- | ---- | ---- |
| Term for external library | "Gem" | "Package" | "Component" |
| End-user configuration file | `.gemrc` | `.npmrc` | `.bowerrc` |
| Per-library configuration file | `*.gemspec` | `package.json` | `bower.json` |
| Cache directory | `~/.gem/` | `~/.npm/` | `~/.cache/bower/` |

As ES2015 (formerly known as "ES6") becomes more prevalent and JavaScript code becomes more
modular and better for passing around, dependency management grows in
importance. Hopefully this quick primer will clear up some
confusion Rubysists have as they transition from working with the
Gemfile to working with the package managers JavaScript offers.
