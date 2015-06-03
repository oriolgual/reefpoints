---
layout: post
title: Integration is Hard
comments: true
author: Chris Gill
github: gilltots
legacy_category: politics
social: true
summary: A description of techniques used to integrate with various vendors on a recent DockYard project for the AFL-CIO's Super PAC Worker's Voice.
published: true
tags: postgresql
---

There's no one-size-fits-all approach to integrating with external
systems because each system comes with its own unique requirements and
constraints.  This article aims to describe some of the varying
approaches we used to integrate with external systems in a recent
project we built for the [AFL-CIO](http://www.aflcio.org)'s Super PAC
[Worker's Voice](http://www.workersvoice.org).

For this project, integration with external vendors was the biggest technical hurdle to clear in order to ensure a successful launch.  The project, called [RePurpose](http://repurpose.workersvoice.org/), gives volunteers and activists a way to choose how the movement's resources get deployed.  The more volunteering and activism a person does, the more RePurpose points they earn, which they can then use to direct the funding of things like more canvassers, direct mail pieces or online ads.  

It's a way to give the people on the ground a say in how the money gets spent.

The volunteering and activism data for which RePurpose points get awarded exists in several separate systems:

* [VAN](http://www.ngpvan.com)

    VAN is the de facto standard tool used everywhere in progressive politics - from small local races all the way up to the Obama campaign.  It's an organizing tool that stores volunteer records, canvass records (door knocks and phone calls), activist codes, and other organizing data used by progressive campaigns and organizations.

* [Salsa Labs](http://www.salsalabs.com)

    Salsa has a platform with a rich API and tools to create fundraising and advocacy campaigns and manage organizer data.  It stores supporter records, online donation records, and pledges to take action - among other things.

* [Amicus](http://amicushq.com/)

    Amicus is a new online tool that leverages Facebook connections of volunteers to enhance fundraising and advocacy campaigns.  It stores a set of volunteer records, friend invite records, and social calling records.

The goal was straightforward - RePurpose needed to know when a volunteer
was performing tasks in external systems, so that the user could receive
points in RePurpose for those tasks.  RePurpose itself has a Task model
that supports multiple kinds of tasks in the various external systems -
survey tasks, activist code tasks, and
[canvass](http://en.wikipedia.org/wiki/Canvassing) tasks in VAN, donation tasks and action tasks in Salsa, and friend invite tasks and call tasks in Amicus.  So a RePurpose administrator could set up a task that would award 10 RePurpose points each time a volunteer knocked on a door, made a phone call, or made a donation.

Here's how we did it in each system:

## VAN Sync ##

VAN, which was recently voted [Most Valuable
Tech](http://rootscamp.neworganizing.com/awards/2012/) at [RootsCamp
2012](http://rootscamp.neworganizing.com/), has a
[SOAP](http://en.wikipedia.org/wiki/SOAP)-based API that allows us to list survey questions, list activist codes, and create and list volunteers (among other things) - all of which we use to get that data into RePurpose, but the API doesn't support retrieving the raw canvasser data - which is the piece we really need to award credit.  To get this data the two options were a nightly sync of flat files, or getting direct access to a replicated database.  We opted for the flat file sync as we knew it had worked for other organizations (among them the Democratic National Committee) and the replicated database approach would have incurred extra time, expense, and risk.

We worked with the great folks at VAN to get a nightly data sync into
place.  Each night around 3am, VAN uploads a zipped TSV (tab-separated
values) export of the relevant data from all the relevant tables in the
AFL-CIO's VAN database.  This is not a delta - because the data size is
relatively low (< 1 GB), we receive the full data dump each night.  We
then unzip, verify that all the files we expect are present, convert
character encodings from
[CP1252](http://en.wikipedia.org/wiki/Windows-1252) to
[UTF8](http://en.wikipedia.org/wiki/UTF-8) (VAN uses [MSSQL
Server](http://en.wikipedia.org/wiki/Microsoft_SQL_Server)), and load
this data into auxiliary tables in the RePurpose database using
[PostgreSQL](http://www.postgresql.org)'s
"[COPY](http://www.postgresql.org/docs/9.2/static/sql-copy.html)" command.  All told it takes about 5 minutes each night to process, load, and index around 700MB of data from flat files to get it into PostgreSQL and ready to be used.  Then based on the new data we award credit to volunteers for completing tasks.  This approach handles the most data of any of the external integrations and does so reliably.  It has one drawback which is that the data can be at most 24 hours stale by the time we receive it, which is not ideal but is certainly workable.  In practice this has not been a problem for us.

## Salsa API ##

Salsa has a
[REST](http://en.wikipedia.org/wiki/Representational_state_transfer)-based
[API](http://en.wikipedia.org/wiki/Application_programming_interface) for authenticating and for creating and retrieving objects in the Salsa system.  For RePurpose, that meant creating and listing supporters (Salsa's name for a volunteer record), listing donation pages, listing donations, and listing completed actions like making a pledge or writing a letter to an editor.  In the context of RePurpose we were most interested in listing completed donations and completed actions so we could award the person who completed the task with their RePurpose points.  Since we could get all this information via the API, and since the API can list objects created since a certain timestamp, we set up a scheduled job to poll the API and ask for anything new that has come in since the last record we retrieved.  This job runs every 10 minutes and gets us pretty close to realtime - if you make a donation through one of the Salsa donation pages that's connected to a RePurpose task, your points will be credited to you within 5 minutes on average.

## Amicus Exports ##

The Amicus API was still a work in progress during the RePurpose project, so we could not use it - but they did have an on-demand user export that could be programmatically triggered.  Since the user export contained all the information we needed about how many calls a user had attempted and how many friends they had invited on Facebook, this would get us where we needed to be.  We would import the Amicus users nightly on a schedule and load them into auxiliary tables in the RePurpose database, which were then used to award credit to the folks making calls and inviting friends.  Since we could trigger the export on demand, we also added a button to the RePurpose admin area to allow administrators to reload the Amicus data on demand and credit any new arrivals.

## Matching ##

You've heard how we get the data into the RePurpose system, but how do we match the volunteers from the various external systems up with the users in RePurpose?  

There are all kinds of pitfalls in implementing person matching, like trying to match up on variations of a first name, or variations of a street address, or keeping track of previous known-good addresses.  Complexity can quickly spiral out of control for marginal benefit.  For this project we went with a simple assumption - all matching would occur via email address.  So if a user was doing things in the field, which gets recorded into VAN - they should use the same email address that they would use to create their RePurpose account.  Likewise for Salsa and Amicus.  Since each of these external systems stores an email address for the volunteer, with this simple assumption, the matching logic becomes simple - comparing lowercase versions of email addresses.

## Awarding Credit ##

There were some wrinkles with awarding credit for tasks performed in external systems.  Since each task hinged on an external datapoint, it was critical to uniquely identify these datapoints.  For most tasks, the granularity of data allowed us to use the primary key of the foreign data source as the unique identifier.  In some cases the data would just be an aggregate count, like "15 calls made" - in which case we would generate our own idempotent IDs for those calls so as to award credit once and have a way to prevent awarding credit for the same call a second time.  In addition to keeping things crediting properly, this had the added benefit of allowing any RePurpose points in the system can be traced back to the explicit data point in the external system that was responsible for creating them.

## Wrapping Up ##

Now that you've seen how we took three different approaches to integrate
with three different systems, you're probably thinking that integration
can be tricky.  But if you're in a progressive organization that uses
VAN, Salsa, or Amicus - remember that [here at DockYard we have the
expertise and experience to make it look
easy](https://dockyard.com/contact).
