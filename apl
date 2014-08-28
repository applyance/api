#!/bin/bash

case $1 in
    dev-into-master)
    git fetch
    git merge --no-commit dev
    git checkout origin/master -- .travis.yml
    git checkout origin/master -- README.md
    git commit -m "Merging dev into master."
    shift
    ;;
    *)
      # unknown option
    ;;
esac
