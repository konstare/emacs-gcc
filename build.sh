#!/usr/bin/env sh
docker build -t konstare/emacs-jit .
id=$(docker create konstare/emacs-jit)
docker cp $id:/opt/deploy .
