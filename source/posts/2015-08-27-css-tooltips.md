---
layout: post
title: 'CSS Tooltips: What clip-path & gradients can do for us'
twitter: 'acacheung'
github: 'acacheung'
author: 'Amanda Cheung'
tags: css
social: true
comments: true
published: true
summary: 'A way to use clip-path and linear gradients to further
customize tooltips.'
---

## What I wanted

This came about when I was trying to create an error tooltip with borders and a transparent background following this design:
![Design for customized tooltip](https://i.imgur.com/baJdTwK.png)

It has a subtle wave texture to it so it was important that the
tooltip held transparency. I also wanted to set up a constraint for myself
to not add extra HTML elements.

## The old solutions and why they didn’t work

Previously, when I wanted to implement a tooltip, I could make it
transparent without a border OR have a border and the background would
have to be opaque. The only way I knew to do borders was stacking the before and after pseudo elements to <i>simulate</i> a border [like so](http://davidwalsh.name/css-tooltips). This method prevented transparent backgrounds because one pseudo
 element had to be on top of the other pseudo element which had a
 background color of the border.

## New ideas

After coming across [Gregor Adams’ Pure CSS Tooltips blog post](http://cssnerd.com/2012/01/08/pure-css-tooltips-transparent-border-box-shadow/), I piggybacked off the idea of using linear gradients to create the triangle of the tooltip.

## Finding a solution

It was a bit strange trying to figure out how to get a triangle with
borders only on two sides without extra surrounding
artifacts (watch what happens when we leave out background-repeat:
no-repeat in the CodePen at the bottom… weird!). Then came finding a
solution for the border around the tooltip. The border had to skip the
portion where the triangle tip sat.

It would’ve been cool if we could control dashed lines to be
able to change the lengths of the dashes or the space in between each
dash. Unfortunately we don’t have that level of customization for
border-style’s. Or if we could use some sort of border gradient with color stops,
but after trying that, I figured out that it didn’t play well with border-radius. Then I thought to use some type of clipping
and I would even be able to angle my clip-path to fit better with my triangle tip! The path I figured worked best is outlined in black:
![Clip-path I used to remove part of tooltip border](https://i.imgur.com/qNTsmqh.jpg)

If you are unfamiliar with clip-path, [Bennett Feely’s tool clippy](http://bennettfeely.com/clippy/) helps visualize clip-path polygons and provides a good starting point with its dragging feature.

<iframe src="http://codepen.io/acacheung/embed/VLoEqa?height=780" scrolling="no" frameborder="0" height="780" allowtransparency="true" allowfullscreen="true" class="cp_embed_iframe" style="width: 100%; overflow: hidden;"></iframe>

It’s not the [DRYest](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself), but it is flexible for tooltips that are multi-line as well
as tooltips that are longer in length. This also works with box-shadows, but clip-path would need to be adjusted and it can also handle transparency for the borders. Unfortunately at this time, Firefox and IE are not
supported because of how clip-path is being used.
