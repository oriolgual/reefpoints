---
layout: post
title: "Why is Google ignoring over 400,000 backlinks to DockYard?"
comments: true
author: 'Brian Cardarella'
twitter: 'bcardarella'
social: true
published: true
tags: opinion, business
---

Imagine our enthusiasm when the opportunity to add hundreds of thousands
of backlinks from one of the web's most popular library hosting websites
back to our domain came our way. And imagine our surprise when Google
decided they meant nothing.

Back in [November we launched the redesign of
RubyGems.org](http://reefpoints.dockyard.com/2014/11/18/rubygems-redesign.html). We were contacted by
[RubyCentral](http://rubycentral.org) about 9 months prior. I was
interested in this opportunity for three reasons:

* It gave DockYard the opportunity to give back to the Ruby community,
  one that has been so pivotal to our growth early on (and one that has
been pivotal to my growth as a professional engineer for nearly 10
years)
* DockYard can show off its design talents to the community
* DockYard would get a *"Designed By"* sponsor link at the bottom of
  every page.

This blog post is going to explore the third reason and the result of
this over the past two months.

At the time of launch RubyGems.org had over 90,000 gems published. This
meant a sponsor link at the bottom of every page that was backlinking
to [DockYard.com](https://dockyard.com). In addition to the landing page
and the other static pages. This was an appealing value to gain from a
re-design effort. According to Google's own backlink search DockYard had
only 65 pages linking back. This struck me as odd considering this blog
itself links back to DockYard.com and there were more than 65 posts. But
surely after the redesign this number should go up. Our estimated
PageRank was `5`.

After the redesign we saw the expected spike in traffic

![](http://i.imgur.com/tpcgGpK.png)

Checking in on the referrals we can see that to date we have received
over 600 referrals from RubyGems.org. I'm OK with these numbers as I
never expected everyone to be clicking on those links.

![](http://i.imgur.com/cM66gW5.png)

However, what did shock me was that none of these backlinks were being
counted by Google.

![](http://i.imgur.com/fTyXVzV.png)

The sponsor link does not have a `nofollow` attribute. And I admit that
SEO is not something I've very good at. But if I were to look at another
backlink source such as
[ahrefs](https://ahrefs.com/site-explorer/overview/subdomains/?target=dockyard.com)

![ahrefs](http://i.imgur.com/tlHt3sK.png)

You can clearly see the spike in referring pages. A **huge** jump from
nearly nothing to over 400,000. The bottom graph shows that these are
primarly *DoFollow* links.

So these backlinks aren't being counted by Google? Does Google only count
one domain per backlink? Color me confused. I suspect we're doing
something wrong on our end to not get any credit. Could it be that such
a huge spike in backlinks are flagged as suspicious by Google? I'd
appreciate any thoughts in the comments.
