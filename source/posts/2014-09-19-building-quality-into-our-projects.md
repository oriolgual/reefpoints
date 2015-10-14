---
layout: post
title: 'Building Quality Into Our Projects'
author: 'Jon Lacks'
tags: quality, engineering, planning, process, project management
social: true
published: true
comments: true
---

This article serves as a continuation of a “Client Targeted” article recently published by our own Michael Dupuis (<a href="http://reefpoints.dockyard.com/2014/09/12/features-as-business-objectives.html">Features As Business Objectives</a>). These posts aim to provide our current and prospective clients insight into how we approach development at DockYard.

Building “Quality” software does not happen by accident. It is actually one of the unspoken sides of the “iron triangle” of project constraints (Scope, Cost, Time) - or should we call it a diamond now? Let’s not go there!
![image](http://i.imgur.com/DEWme3R.jpg)

When making an investment in development of an application, the level of desired quality influences project cost and schedule.  Building an appropriate Quality Plan for a project requires time, planning and execution which is the responsibility of DockYard and the clients with whom we engage.  Below I layout the primary types of quality related practices we may consider applying to our (your) projects; always driven by clients’ unique context (See my earlier blog post about context driving practices - <a href="http://reefpoints.dockyard.com/2014/06/06/process-paradox.html">Process Paradox</a>).  This article does not serve to describe these quality practices in depth but will cover the basics in terms of how they could apply to client projects.  Any one of these practices in isolation is not an effective recipe for quality, it is the degree to which these practices are commingled in a logical way that results in positive outcomes.

## Practice #1 - Test-Driven Development / Automated Testing

Before the Engineer writes a line of code they are investing time in thinking about and writing the appropriate test cases for the code - these tests will serve as a functional quality benchmark which the engineer can code towards. In parallel these efforts build up a library of automated tests that will ensure that the “working” features built early in the project continue to work when new features (code) are introduced later on.  If we don’t have these tests and we have 1000’s of lines of code, testing/debugging overhead raises exponentially which will result in increased risk to project cost and/or desired schedule.  It’s also important to note that this practice is functionally-centric and not visual which is addressed with other practices described below.

***What this means to the client***

The cost and eventual savings related to this practice manifest themselves as time spent thinking vs. coding vs. testing. When we estimate what it will take to develop a given feature, we consider the time spent thinking about these tests, writing the tests, maintaining the tests in addition to writing the feature code.  However, keep in mind that the time spent testing later on in the project, when the code base has grown exponentially, is reduced due to this upfront investment of time (see figure below) because we have a growing set of automated tests that will ensure we continue to maintain high quality throughout the development cycle.

![image]( http://imgur.com/2HBq9ie.jpg)
## Practice #2 - Pair Programing / Code Reviews

Sometimes (usually) two heads are better than one.  Pair Programming is exactly as it is described. Two engineers team up to work side by side on a single unit of code (or feature.) In a 2013 article published by the Economist a study conducted by Laurie Williams of the University of Utah showed “*...paired programmers are 15% slower than two independent individual programmers, while "error-free" code increased from 70% to 85%. Since testing and debugging are often many times more costly than initial programming, this is an impressive result. Pairs typically consider more design alternatives than programmers working alone, and arrive at simpler, more maintainable designs; they also catch design defects early.*”

Additionally, Code Reviews by a peer or more senior engineer serve to ensure that the code being written meets agreed best practices and that mistakes of the past don’t get reintroduced.

***What this means to the client***

Pair programing and Code Reviews are practices DockYard believes yield higher quality code while also establishing a continuous learning culture across our engineering team.  The extent to which we apply these practices is less variable in that it is part of our company DNA - however, like any practice, a client’s project context will dictate the extent to which these apply.  The client will incur the benefit of a well rounded and productive engineering team which can translate to reduced project cost.

## Practice #3 - Manual Testing

In a literal sense this is the type of testing conducted by a human who seeks to ensure the less common use cases which may not have been exercised by an Automated Test or code review are working as expected. Additionally, this type of testing ensures the visual design of the product has been upheld -  Spacing, pixels, colors, fonts, etc.  Browser compatibility is also something manual testing will verify. This type of testing is usually conducted by members of the project team and the client. They work in collaboration across the feature set, report and classify severity of bugs which are eventually assigned to engineers when appropriate.

***What this means to the client***

The client should be prepared to be a very active participant in this practice and schedule their time accordingly.  Feature complexity will drive the amount of time required for this type of testing - which might be nil if complexity is low.  A very rich user experience will require more testing and thus manifest itself in terms of increased time/cost.

## Practice #4 - Client Demos (and Acceptance Testing)

For most projects we work in 1-2 week iterations (sprints) and at the conclusion of this time period we typically demonstrate the progress we have made by sharing working software. These demonstrations serve a dual purpose:

1. gives the client opportunity to verify development is proceeding in the desired direction, and if not, attempt to course correct early on vs. late in the project when course correction can be very costly
2. allows the team to reflect and continuously improve how they are executing the project.

When a feature is ready for prime time, we will usually ask the client to formally accept the feature as complete.  This ensures the team can shift their full focus and attention to building the next features on the backlog. Context switching can be very costly in terms of productivity, therefore we try to call things “Done Done” before moving on.

***What this means to the client***

Similar to manual testing, client should be prepared to be a very active participant in both demos and conducting acceptance testing within agreed timeframes.  Deviation from established timeframes will result in increased project cost/time.  Therefore, whenever we engage with a client, we request upfront a high level of collaboration and availability to keep things moving along.

Hopefully after reading this article, you have gained an appreciation for some of the considerations we make in terms building quality into our projects.  The level of quality a client desires and the pride DockYard has in its deliverables drives the extent to which these practices are utilized.  Therefore, if you are interested in engaging with us, think about the level of quality you expect and we will work together to derive an appropriate quality plan that balances your cost and time constraints.
