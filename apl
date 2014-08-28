#!/bin/bash

case $1 in
    dev-into-master)
    git merge --no-commit dev
    git checkout .travis.yml
    git checkout README.md
    git commit -m "Merging dev into master."
    shift
    ;;
    *)
      # unknown option
    ;;
esac
