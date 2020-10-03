#!/usr/bin/env sh
docker build --force-rm --no-cache . -t emacs-jit/build
id=$(docker create emacs-jit/build)
docker cp $id:/opt/deploy .
