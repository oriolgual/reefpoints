---
layout: post
title: "Introducing Ember-EasyForm"
comments: true
author: "Brian Cardarella"
twitter: bcardarella
github: bcardarella
legacy_category: ember
social: true
summary: "A SimpleForm-like FormBuilder for Ember"
published: true
ember_start_version: '1.0'
tags: javascript, ember libraries
---

[View the project on GitHub](https://github.com/dockyard/ember-easyForm)

One of the more tedious tasks in Ember is writing forms. It is not
uncommon to have to write something like so:

```handlebars
<form>
  <div class="input string">
    <label {{bindAttr for="firstNameField.field_id"}}>First name</label>
    {{view Ember.TextField valueBinding='firstName' name='first_name' viewName='firstNameField'}}
  </div>
  <div class="input string">
    <label {{bindAttr for="lastNameField.field_id"}}>Last name</label>
    {{view Ember.TextField valueBinding='firstName' name='last_name' viewName='lastNameField'}}
  </div>
  <div class="input string">
    <label {{bindAttr for="ageField.field_id"}}>Age</label>
    {{view Ember.TextField valueBinding='age' name='age' viewName='ageField'}}
  </div>
  <input type="submit" value="Submit">
</form>
```

And this is just a very simple form, but what if we could write this:

```handlebars
{{#formFor controller}}
  {{input firstName}}
  {{input lastName}}
  {{input age}}
  {{submit}}
{{/formFor}}
```

That is *much* more concise! We pass the `controller` as the context to
the `formFor` Handlebars helper. Then we can simply call `input` for
each property we want.

By default `EasyForm` will use text fields for the rendered input.
However, in certain cases it will attempt to properly set the `type`. If
the property contains `email` the `type` will be set to `email` or of
the property contains `password` the `type` will be set to `password`.
You can override this and set the type yourself:

```handlebars
{{input code type="hidden"}}
```

Currently the only other input type supported is `textarea`, you can
create one with:

```handlebars
{{input bio as="text"}}
```

I plan on adding support for the other input types such as `select` in
the next few weeks.

## Validations ##

This implementation has basic support for property validations.
Currently it works with `ember-data-validations` but that project might
get rolled into a larger Ember Object Validation effort and at that time
I will change `ember-easyForm` to support whatever that is.

Validations will fire on `onFocusOut` for each input and will render
into a `<span class="error">` element associated with the given input.

If your model doesn't have validations this behavior will be ignored.

## Form Submit ##

The `submit` helper will render a submit input but you can just write
one yourself if you wish. The `onSubmit` action for the wrapping `form`
element will do the following:

1. Attempt to validate for object. If validations are not supported it
   will go to step 3.
2. If validations fail form submit is interrupted and errors are
   rendered. If not go to step 3.
3. The view for the `form` element will attempt to call a `submit`
   action on the controller. This is an action that you need to supply
yourself:

```javascript
App.NewUserController = Ember.ObjectController.extend({
  submit: function() {
    // handle form submit here
  }
});
```

## More to come! ##

This is very close to what I recently (and briefly) showed at
[EmberCamp](http://www.embercamp.com)
last week. I hope to continue to build this project into a form builder
that evrerybody will be happy to use. [Please feel free to propose new
idea in the issues for this project on GitHub](https://github.com/dockyard/ember-easyForm/issues)
