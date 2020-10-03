#!/usr/bin/env bash
set -e
git clean -xdf
git pull
bash ./deploy.sh
bash ./pack.sh
