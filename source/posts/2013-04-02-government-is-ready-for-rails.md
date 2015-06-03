---
layout: post
title: "Government is ready for Rails"
comments: true
author: Brian Cardarella
github: bcardarella
twitter: bcardarella
legacy_category: ruby
social: true
summary: "And not the other way around"
published: false
---

The government software contract space is dominated by large, slow
moving, industry titans. .NET and Java are their tools of choice. At
DockYard we aim to liberate government of these systems while at the
sam$ie time giving agencies the agility of a quicker built project, with higher
quality, and for less money. Read on.

## Make room for the new boss ##

Government is changing. Years ago Waterfall was all the rage, and for
the most part still is. It is understandable why Waterfall and
government got along so well: they are both very much top-down concepts.
However, there is change in the air with more and agencies buying in
Agile Development.

Rails, for those unfamiliar, is short for Ruby on Rails. It is a web
framework that has been around since 2005. Built using the award-winning
software language Ruby it is meant to be opinionated in nature and allow
developers to not worry about the nonsense that exists in other
languages in frameworks. Rails allows developers to work on business
features, no more mucking around having to re-invent the wheel each
time. And it is all free. Development happens more quickly in Rails than
.NET brecause there is we avoid the black box of closed-source software.
Is something not working as expected? We can read the source code, make
the change ourselves. We don't have to wait for Microsoft and we don't
have to pay Microsoft for support so those savings get passed back to
the client.

Ruby and the Rails framework have much more in common with the Java
eco-system than Microsoft's but many of there was a conscience effort to
avoid much of the ceremony and overhead that exists in Java and focus on
a framework and language that allowed us to "get stuff done".

The proof is out there, start-ups have known this for a long time. Rails
is the most popular framework amongst them. Enterprise is catching up.
More and more often we are being contacted by large companies that are
looking to create new application or re-write existing ones in Rails
because they have heard of the benefits.

Agile is a core philosophy in Rails. Most Rails developers are doing
Test Driven Development and most Rails consultancies and companies are
practicing Agile.

Let's address some of the concerns that some in government might have
about Rails:

### Security ###

Security is the most important concern for any government agency that is
building a software project. While it is true that .NET and Java are
traditionally thought of as leaders in this aspect the reality is that
Rails is every bit as good. In fact, in some cases perhaps better.

The first part about security you should understand is that most of the
security is out of the hands of the framework itself. This includes the
people, the server, and the database.

#### People ####

Government is already handling this level of security very well.
Clerance requirements and have trust-worthy people that are accessing
the system are always the first line of defense.

#### The Server ####

Rails apps typically run on Linux-based servers and
I would argue any day of the week that a Linux server properly locked
down is more secure than any Microsoft based server. And did I mention
that Linux is free? No more license fees, but finding a good Linux
sys-op is not easy. If you have one on staff, pay that person very well.
We at [DockYard](https://dockyard.com) are very experienced in Linux. I
personally recommend using CentOS as it is (out of the box) the most secure of all the
Linux distributions out there.

Some of the obvious things to do for locking down Linux:

* closing all ports except 80 (to allow web connections)
* only allowing user processes to run the web app (and potentially
  database depending upon the app)
* we use nginx as a proxy server to our Rails apps. Generally this is
  the only process that we allow to run as a super user (accessing port
80 requires super user access)

#### The Database ####

The database is the next layer of
security. We prefer PostgreSQL, it is a far better choice than MySQL in
our opinion and can go toe-to-toe with Microsoft SQL Server or Oracle
any day of the week on nearly every feature.

### Security in Rails ###

Now onto the framework itself. Out of the box Rails has baked-in Bcrypt
authentication. Bcrypt was developed by the NSA and can be fine tuned to
just how secure a system is desired. We can increase the complexity and
passwords become more and more difficult to decrypt. At
[DockYard](https://dockyard.com) we have built a Rails Engine (plugin)
called EasyAuth that allows us to quickly build out very secure identity
based accounts. By default is uses Bcrypt but we can quickly swap that
out for different authentication strategy. We take security very
seriously.

Rails handles SQL injection automatically. All queries that are passed
through ActiveRecord (the Rails package that interacts with databases)
are sanitized of any potentially malicious queries.

Rails also automatically handles all HTML and JavaScript injection by
user input. All data that Rails displays on page is automatically
santized. In fact, if you want to show the raw data we have to
explicitly flag that data to allow the unsanitized data 

### Internationalization (i18n) ###

As of Ruby 1.9 (current version is 1.9.3 with 2.0 just around the
corner) Ruby itself has met the most stringent internationalization
standards. It has fully implemented UTF-8 engine. Rails itself has a
fully implemented i18n feature that allows for very quick to develop
multi-lingual applications. We can simply drop in what i18n text block
we want then provide that text in a global i18n file. We can even set up
a quick to edit system so that translators can directly edit and have
control over the given content rather than passing translations back to
the development team. Another example of the efficiency of using Rails.

### Globalization (time) ###

Rails has automatic UTC offsets built in. Any Rails app can be defaulted
to a given timezone. All datetime data is written to the database as
UTC-0. Then custom offsets can be assigned to user accounts. This is out
of the box in Rails and takes moments to implement. 

## Security Vulnerabilities ##

[Every](http://www.cvedetails.com/vulnerability-list/vendor_id-26/product_id-3091/Microsoft-Asp.net.html)
[major](http://www.cvedetails.com/vulnerability-list/vendor_id-93/product_id-19116/version_id-127974/Oracle-JDK-1.7.0.html)
[framework]
