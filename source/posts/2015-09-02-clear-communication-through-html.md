---
layout: post
title: 'Clear communication through HTML and GitHub'
twitter: 'ctannerweb'
github: 'ctannerweb'
author: 'Cory Tanner'
tags: HTML
social: true
comments: true
published: true
summary: 'A technique for clear communication between web application teams through HTML and GitHub'
---

If you follow the DockYard blog I am sure you are familiar with how we structure our teams.

**Design**

You can get a feel for how our designers operate by taking a look at Steve's post, [Job: Senior UI & Visual Designer](https://dockyard.com/blog/2015/01/14/sr-ui-designer).

**UX Dev (User Experience Development)**

Brian has a great post describing the UX Dev team, [The most difficult position to hire for in tech right now](https://dockyard.com/blog/2014/08/06/the-most-difficult-position-to-hire-for-in-tech-right-now).

**Development**

Mainly with [Ember.js](http://emberjs.com/) the Development team wires up all of the functionality required with the HTML and CSS provided by UX Dev.

## Our current process

What helps us the most when we have multiple teams on a project is clear communication.

DockYard has methods of communication between all three teams but this blog post will be focusing on methods the UX Dev team uses to communicate with the Development team.

Our UX Dev team is always looking to make work easier for the Development team and a simple way to do that is through how we communicate an application's conditionals. When we receive designs of the application we need to communicate to Development what the conditionals are in a clear and organized way.

We have done this through our HTML templating comments and this alone has worked well.

In a previous post we went over how to add comments to your code in [Helping Our Engineers](https://dockyard.com/blog/2015/03/31/helping-our-engineers), and we go over two methods of communication.

**Note:** we use [Handlebars](http://handlebarsjs.com/) for our templating.

### Pseudo-code comments

```hbs
<a class="t-link" href="">about</a>
<a class="t-link" href="">contact</a>
{{! if signed in}}
  <a class="t-link" href="">manage</a>
{{! else}}
  <a class="t-link" href="">sign in</a>
{{! end if}}
```

This lets our developers know that `if` the user signs into the application, the manage link is added to the HTML, `else` the sign in link should be present.

This method works great for adding notifications to the page, you just need to say the following.

```hbs
<input class="button">Log In</input>
{{! if <input> has errors on submit}}
  <div class=“notification”>
    ...
  </div>
{{! end if}}
```

### TODO comment

```hbs
{{! TODO: Toggle class .is-selected on <a> when active}}
<a class="t-link" href="">about</a>
<a class="t-link" href="">contact</a>
```

If we don’t need to add complete blocks of code to the HTML we will use a TODO comment to let the developers know a class needs to be added to the next line of code.

## What’s new: Track Everything

In addition to adding comments it is recommended to provide a trackable issue referencing the comment in your code. On GitHub this is very easy and we can assign the issue to a team member.

We don’t do this for every individual comment but rather make a checklist in the GitHub issue per modular [component](http://emberjs.com/api/classes/Ember.Component.html) or one issue for simple pages.

An example of a simple page would be a static "About Us" page that only has about 1 - 2 comments and no complex conditionals.

### Issue example

![GitHub issue for component comments](http://i.imgur.com/8VHiilm.png)

Having trackable issues for comments is helpful because there can be so many of them. Keeping everything organized in a project management system like GitHub is very helpful.

### Final Thoughts
Our goal as UX Developers is to provide crystal clear communication with the Design and Development teams so the client gets the best product possible.

Having standardized techniques for communicating the application HTML conditionals within your team can greatly help the workflow and make everyone's life easier.

I hope this helps your templating process with HTML and provides clear communication with your team!
