#!/usr/bin/env sh
docker build -t konstare/emacs-gcc .
id=$(docker create konstare/emacs-gcc)
docker cp $id:/opt/deploy .
