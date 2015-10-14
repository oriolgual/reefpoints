---
layout: post
title: 'KSS Your Styleguide Goodbye'
author: 'Christopher Plummer'
tags: tools, process
social: true
published: true
comments: true
---
Styleguides are a place where developers and designers can find authoritative information about how elements are to be styled throughout a project. Contributors can always refer to a styleguide to help them create new pages and elements. Careful attention to a styleguide can prevent a contributor from designing or developing components that don't conform to the designers' vision.

Most styleguides are created by designers and developers prior to development to guide the translation of comps into code. In a perfect world, that styleguide is a living document that is updated as changes are made to the design. This often doesn't happen. As changes are made throughout a project's development cycle, the styleguide is rarely updated. At some point on almost every project, that styleguide is no longer a reliable, authoritative document.

If only there was a better way...

## Enter KSS

[KSS](http://warpspire.com/kss/) is a methodology and set of tools that will help you create automated, living styleguides. Through the KSS menting syntax and the KSS parser, the guide can be updated automatically throughout the development cycle. All those little adjustments and decisions that happen in conversations outside your documented channels will be reflected in your KSS styleguide. In theory, the styleguide will show the most up-to-date styles. KSS styleguides also render element states like `:hover` as you can see in this [example from GitHub](https://github.com/styleguide/css/):

![GitHub Styleguide](/images/github-styleguide.jpg)

A KSS styleguide can be designed to reflect the look and layout of your project using existing styles:

![Two KSS Styleguides](/images/kss-styleguide-examples.jpg)

**KSS isn't magic. It's not going to create the styleguide for you.** You still have to do a lot of custom configuration and coding. Coding the styleguide starts with commenting your CSS. You have been leaving helpful comments for future developers all along, right? KSS [defines a syntax](http://warpspire.com/kss/syntax/) for these comments:

```sass
// Short description of the element to be documented
//
// :hover             - description of this modifier.
// .disabled          - description of this state class modifier.
//
// Styleguide x.x.x. Section Name and/or Number
.element-to-be-documented {
  ...
  &:hover{
    ...
  }
  &.disabled{
    ...
  }
}
```

A KSS parser like [this one for ruby](https://github.com/kneath/kss) parses the elements of those comments – the description, modifiers, and section – and applies it to a partial like this:

```erb
<div class="styleguide-example">

  <h3>
    <%= @section.section %>
  </h3>
  <div class="styleguide-description markdown-body">
    <p><%= markdown h(@section.description) %></p>
    <% if @section.modifiers.any? %>
      <ul class="styleguide-modifier">
        <% modifiers.each do |modifier| %>
          <li><strong><%= modifier.name %></strong> - <%= modifier.description %></li>
        <% end %>
      </ul>
    <% end %>
  </div>

  <div class="styleguide-element">
    <%= @example_html.gsub('$modifier_class', '').html_safe %>
  </div>
  <% modifiers.each do |modifier| %>
    <div class="styleguide-element styleguide-modifier">
      <span class="styleguide-modifier-name"><%= modifier.name %></span>
      <%= @example_html.gsub('$modifier_class', " #{modifier.class_name}").html_safe %>
    </div>
  <% end %>

  <div class="styleguide-html">
    <%= @example_html %>
  </div>
</div>
```

You'll also need to create a controller, a template, helpers, and a front-end KSS script to render the styleguide. It's a lot of up-front work, but there are examples and parsers already written for Node.js, Ruby, PHP, Sinatra, Rails, and so on.

## Why use KSS?

**If standards, methodolgies, and tools are your thing, you'll like KSS:**

- The kss.js script can render elements with different states (called modifiers by KSS) directly in the styleguide blocks. For example, buttons with `:hover`, `:focus`, `:active`, states or even modifier classes like `.red`, `.is-active`, or `.disabled` will be automatically added to the styleguide allowing readers to see every possible state at once.

- CSS comments and styleguide documentation are bound together in the stylesheets, not some other styleguide-specific template. UX developers can comment the stylesheets they work in most while they're working in them.

- The styleguide templates can also include markup codeblocks, allowing readers to see the markup elements necessary to generate a component.

## Why not use KSS?

**If you're in the "tools are bullshit" crowd, you're going to hate KSS:**

- Styleguides created with KSS are only as reliable as the CSS and markup used to generate them. If an element is changed in a way that no longer conforms to the design comps, the styleguide will no longer reflect the correct way that element is supposed to be styled. For example, a developer might change the border radius of a particular button for a new page and doesn't realize that he or she has just changed the base button style in the styleguide. Now the button entry styleguide is no longer a reliable representation of the styles established in the design comps.

- When elements are taken out of their context it can change how styles are applied. Elements have to be adjusted and changed just to appear correctly in the styleguide. This is work beyond what is strictly required to develop a site.

- Styleguide-only styles and markup might be confusing to developers joining a project. The rules and markup in the styleguide aren't necessarily the same rules or markup used in the site. When creating new elements that follow from a styleguide entry, simply copying the elements as they appear styleguide could cause layout and style problems.

- The KSS documention is spread out over many files. Nothing is centralized. Simply restructuring the styleguide, editing sections, or even adding new items requires sifting through many CSS files and templates. And when styles for elements are duplicated or spread across several pages, where do we put the documentation?

- Deciding what goes in the styleguide and how it is documented becomes another tangle of challenging questions. How do we describe this element? How to we organize the guide? What do we include?

## KSS Is Just Another Thing

The strength of KSS – automation – is also the source of its weakness – mutable elements. If the styleguide can be updated automatically, it can also be sabotaged accidentally. The styleguide must be QA'ed alongside the site to ensure that it conforms to the design comps and that it accurately illustrates elements as they appear in the actual site pages. Developers must take care to pay attention to styleguide-only rules and markup.

You could generate a static styleguide in your comping tool of choice as a definitive reference against which to check the living styleguide. But then you're just creating more documents that must be updated. You haven't solved the original problem.

Implementing KSS requires additional UX Development and Design resources (additional QA, more templates, styleguide-only styles, controllers, etc.), but may save resources spent creating and updating a static styleguide.

KSS is not a perfect solution to the problem of maintaining living styleguides. You'll simply have to try it in your workflow to evaluate its utility.
