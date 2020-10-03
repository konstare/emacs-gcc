#!/usr/bin/env bash
set -e
git clean -xdf
bash ./build.sh
bash ./pack.sh
