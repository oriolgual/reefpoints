#!/usr/bin/env bash

set -e

git config --global user.email "socko@dockyard.com"
git config --global user.name "sockothesock"


# This specifies the user who is associated to the GH_TOKEN
USER="sockothesock"

# sending output to /dev/null to prevent GH_TOKEN leak on error
git remote rm origin
git remote add origin https://${USER}:${GHTOKEN}@github.com/dockyard/reefpoints.git &> /dev/null

# Push build/posts.json to homeport.dockyard.com
bundle exec rake build

chmod 600 ./reefpoints_deploy
ssh-keyscan -H homeport.dockyard.com >> ~/.ssh/known_hosts
scp -i ./reefpoints_deploy build/posts.json temp_deploy@homeport.dockyard.com:reefpoints/posts.json
scp -i ./reefpoints_deploy build/new_sitemap.xml temp_deploy@homeport.dockyard.com:reefpoints/sitemap.xml
scp -i ./reefpoints_deploy build/new_atom.xml temp_deploy@homeport.dockyard.com:reefpoints/atom.xml

echo -e "Done\n"
