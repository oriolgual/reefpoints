---
layout: post
title: "Copy to Clipboard without Using Flash!"
comments: true
social: true
author: Marin Abernethy
twitter: "maabernethy"
github: maabernethy
summary: "`document.execCommand()` has now added support for `copy` in some browsers"
published: true
tags: javascript
---

For a long time we've had to rely on Flash plugins like [ZeroClipboard](https://github.com/zeroclipboard/zeroclipboard) 
to copy text to the clipboard. While Flash still remains the only cross-browser solution for copying to a user’s clipboard, 
some browsers have recently added the ability to trigger `cut` and `copy` using `Document.execCommand()`! Specifically, 
[IE10+, Chrome 43+, and Opera29+](http://caniuse.com/#search=clipboard%20API). Firefox seems to have some
[options](http://kb.mozillazine.org/Granting_JavaScript_access_to_the_clipboard) that allow users to grant permissions 
to certain sites to access the clipboard, but I haven't tried it out myself.

For those of you not familiar with `execCommand()`, it is  more than just `cut` and `copy`! It is one of the core methods
of rich-text editing in browsers. You can manipulate the contents of the current document, current selection, or a 
specified range through various commands. Some other common commands include: `bold`, `delete`,  `createLink`, and 
`indent`.

**`execCommand(commandName [, showUI [, value]])`**

  * `commandName` (String): the property that you are validating.
  * `showUI` (Boolean) *optional*: Display a user interface if the command supports one. Defaults to false.
  * `value` (DOMString) *optional*: Specifies the string, number, or other value to assign. Possible values
depend on the command. Pass an argument of null if no argument is needed.

However, take note that, like `cut` and `copy`, not all commands are enabled across all browsers. I created 
an [Ember JSBin](http://emberjs.jsbin.com/hagupu/3/edit?html,js,output) with a simple WISYWIG
to demonstrate some of what `execCommand()` can do. Feel free to play around!

Now to demonstrate how `execCommand` paired with the Selection API can easily copy to a user's clipboard. 
Below is our HTMLBars with a promo code string that we want to copy.

```
<p>Promo code: <span class="promo-code">SALE123</span></p>
<p><button {{action 'copyToClip'}}>Copy</button></p>
```

When the `Copy` button is clicked, the following action will be called:

```js
copyToClip: function() {
  const promoCode = document.querySelector('.promo-code');
  const range = document.createRange();  
  range.selectNode(promoCode);  
  window.getSelection().addRange(range);
  document.execCommand('copy'); 
  window.getSelection().removeAllRanges();
}
```

In this action we create a range of the document and add our promo code text as a node of that range. We then 
use the Selection API method `window.getSelection().addRange()` to add the part of the document we want to copy
to the user's `selection`. `document.execCommand('copy')` then copies that selection to the clipboard. 
And finally, we remove the selection by calling `window.getSelection().removeAllRanges()` so that the user 
never sees the highlighting.

And thats it! If you wanted to confirm everything worked as expected you can examine the response of 
`document.execCommand()`; it returns `false` if the command is not supported or enabled.

You can checkout this example out in this [Ember JSBin](http://emberjs.jsbin.com/faqixa/3/edit?html,js,output).
