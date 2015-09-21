---
layout: post
title: "Rubyist's Guide to Executing JavaScript"
comments: true
author: Michael Dupuis
twitter: "michaeldupuisjr"
github: michaeldupuisjr
social: true
summary: "A high-level look at how your Ruby and JavaScript code gets
executed."
published: true
tags: ruby, javascript
---

JavaScript is introduced to developers as a programming language that runs client-side, in the browser. This is convenient as a jumping off point for aspiring programmers, who can simply open up Chrome’s Web Inspector and start alerting “Hello, World!”, but it’s a concept that isn’t easy to unpack. Soon enough, the developer will likely find herself in contact with JavaScript outside of the browser – Node.js being the most prominent example of this. At this point, the notion of JavaScript being a language for the browser is no longer helpful; it obfuscates what is happening when a developer executes a line of code.

This post is a high level primer on what is happening “under the hood” with our code. It will lend some insight into what terminology like “tokenizing,” “interpreting,” “compiling,” and a host of other terms mean. You'll gain a better sense of what the concept of a virtual machine encapsulates. And hopefully you'll leave with a better understanding of what your script is doing before it hits your computer's processor.

I feel this article will be well-suited for Rubyists who find themselves increasingly working in the realm of JavaScript, as I’ll be comparing how code executes between the two languages.

Rather than explaining how a line of Ruby or JavaScript code gets processed and run, I’d like to work our way backwards, beginning with machine code. When you write a line of Ruby, it doesn’t simply go to the processor when you run the script. It goes through a number of translations before being turned into machine code that the processor can execute. We’ll look at how Ruby gets processed and then touch on how JavaScript differs.

## Ruby
![Ruby execution diagram](http://i.imgur.com/Sa1qURz.png)

### Machine code
Machine code is binary that is executed directly by your computer’s CPU. The bit patterns correspond directly to the architecture design of the processor.

Before a statement in a scripted language becomes machine code, it gets compiled into machine code by a compiler.

### Virtual Machine
[LLVM](http://www.aosabook.org/en/llvm.html) compiles code on most
Unix-based machines. It generates the machine code for the processor
during compilation, which is just the process of translating one language to another.

The virtual machine executes your code. It's written in C and is known as the [YARV](http://en.wikipedia.org/wiki/YARV) interpreter. It is at the heart of a scripting languages "implementation," as it executes the source code via whatever language the scripting language is built upon ([C](http://en.wikipedia.org/wiki/C_(programming_language)) in the case of [Ruby MRI](http://en.wikipedia.org/wiki/Ruby_MRI)).

YARV doesn’t receive the Ruby statement as you typed it. It goes through an abstraction of your code known as an [Abstract Syntax Tree (AST)](http://en.wikipedia.org/wiki/Abstract_syntax_tree), which get compiled to YARV byte code and run.

This "tree" is made up of nodes assembled by something called the parser.

### Parser
You can think of a node on the Abstract Syntax Tree as an atomic representation of a Ruby grammar rule. The reason that Ruby knows to print “Hello, World” when it sees `print 'Hello, World'` is because the parser knows that `print` is a method and the string `'Hello, World'` is its argument. These syntax rules are located inside of a language’s grammar rule file.

Again, the parser creates the Abstract Syntax Tree that the virtual machine compiles and interprets.

### Tokenizer/Lexer
If you’re wondering how Ruby knows that `print` is a separate element in the language from `'Hello, World'`, then you’re understanding the function of the Lexer or Tokenizer. The Tokenizer scans your line of Ruby code, character-by-character and determines where the "words" of the language begin and end. The Tokenizer can tell the difference between a space separating words and a space separating a method name from its arguments.

And that’s the 10,000 foot lifecycle of a Ruby statement, as it goes from Tokenization to becoming machine code. If you’re looking for the microscopic explanation, I’d recommend [Ruby Under a Microscope](http://www.nostarch.com/rum).

## JavaScript
### Client-side
Most browsers implement [Just-In-Time (JIT) compiling](http://en.wikipedia.org/wiki/Just-in-time_compilation). This means that the JavaScript code you write is compiled right before it gets executed by the virtual machine; though, in JavaScript, the interpreter is not referred to as a virtual machine, but as a JavaScript engine.

V8 is the engine that interprets and executes JavaScript in the Chrome browser, Nitro is the engine for Safari, SpiderMonkey for Firefox, and Chakra on Internet Explorer. The efficiency with which a browser interprets JavaScript accounts for a substantial portion of its performance these days, especially as JavaScript-heavy, Single Page Applications become increasingly important.

### Server-side
Node.js is the predominant framework for running JavaScript server-side. It is built on top of Google’s V8 engine, which is a little confusing if you’ve just read that V8 interprets JavaScript in the browser. In general terms, the JavaScript interpreter is extracted from Chrome, compiled on the server, and utilized by Node.js, allowing you to execute JavaScript outside of the browser.

## Conclusion
Upon researching how a line of Ruby or JavaScript gets executed, you'll quickly find that you can go down a rabbit hole. There are so many different implementations of Ruby, so many advancements in how code gets processed, and so much ambiguity in the terminology we use, that it can be quite challenging to form a mental model of what's going on under the hood. That being said, a little patience goes a long way, and if you're looking to dive into any one of the topics described above, I think you'll be surprised at how readable much of the technical documentation is out there.
