---
layout: post
title: 'Simple Property Enum Cycling in Ember'
comments: true
author: 'Brian Cardarella'
twitter: 'bcardarella'
github: bcardarella
social: true
summary: 'A quick demo of cycling between a set of values'
published: true
tags: ember
---

This is a quick one. I needed to cycle between the values in a set.
Toggling between `true` and `false` in Ember is easy enough with the
`toggleProperty` function but I had several properties I wanted to cycle
between. So last night I wrote a simple function poorly named:
`cycleEnumProperty`. You pass it the property you want to act upon and
the enum set to cycle. If the property is currently empty or if the
property matches the last value in the set the property will be set to
the first value, otherwise the property will be set to the next value.
Try it out:

<iframe class="jsbin-embed" src="http://emberjs.jsbin.com/agaKuCoL/1/embed?js,output"></iframe>
