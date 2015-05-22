---
layout: post
title: "Testing when your frontend and backend are separated"
comments: true
author: Dan McClain
twitter: "_danmcclain"
googleplus: 102648938707671188640
github: danmcclain
social: true
summary: "How can you run full integration tests when using separate repos?"
published: true
tags: ember, testing
---

The last project I worked on was an Ember app that had a Rails backend that was
deployed on Heroku. We had this application as a single repository, where there
were two folders at the root, `frontend` and `backend`. This was somewhat easy
to test on Travis-CI; it would check out the one repository, run the Rails
tests, start the Rails server, then run the ember tests that hit the Rails
server. This ended up being a pain to deploy, as when you changed the Rails app,
you were going to redeploy the Ember app, and vice-versa.  It also presented an
issue when deploying to Heroku, as [we had to utilize `git subtree` to push
the backend](https://www.youtube.com/watch?v=ceFNLdswFxs&t=4103), which
contained the production assets.

With the latest project I started, I'm keeping the backend and the Ember app
separate.  Since the apps are separate, they can be deployed independant of
each other. This made it a little bit harder to run integration tests against
the backend.

**Side note:** while you can mock/stub your API in your Ember tests, it is
important to run integration tests against your backend regularly. When you
mock your API, it ends up giving you this false sense of security when it comes
to your Ember app being compatible. Your models may line up perfectly with your
mocks, but your mocks can fall out of date. To prevent this, at least when
running on your continuous integration (CI) server, you should have your Ember
app hit the backend server.

To run end-to-end integration tests on Travis-CI, I added tasks to the
`.travis.yml` file to clone the backend repository, install dependencies, and
run the server:

```yml
language: node_js
node_js:
  - "0.12"

sudo: false
cache:
  directories:
    - node_modules
    - backend
    - vendor/bundle

before_install:
  - npm config set spin false
  - npm install -g npm@^2
  # Select the RVM version
  - rvm use 2.2.1 --install --binary --fuzzy
  # Clone the repository if isn't cloned
  - "[ -d backend/.git ] || git clone git@github.com:<backend-repo> backend"
  - "cd backend"
  # Reset the repo so we can have a conflict-less pull
  - "git reset --hard"
  - "git clean -f"
  - "git pull"
  # Install dependencies
  - "bundle install --path=../vendor/bundle --jobs=3 --retry=3 --deployment"
  # Run the server
  - "RAILS_ENV=test ./bin/rails s &"
  # Wait for the Rails app to start
  - "sleep 5"
  - "cd .."

install:
  - npm install -g bower
  - npm install
  - bower install

script:
  - npm test
```

Note that I cached both the backend and bundle directories to speed up the time
it takes to get the backend running. Since the backend is cached, we only have
to pull the new code.

In this example, we have a Rails app with no database, but it would be pretty
easy to add one. The only other required step was to add an SSH private key to
the Travis settings, since you would have two separate deploy keys. That would
prevent you from cloning the backend repository from the frontend test.  There
should be nothing holding you back from performing end to end tests when you
have separate repositories!
