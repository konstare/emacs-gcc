#!/usr/bin/env sh
docker build . -t emacs-jit/build
id=$(docker create emacs-jit/build)
docker cp $id:/opt/deploy .
