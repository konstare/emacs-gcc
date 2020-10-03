#!/usr/bin/env bash
if [ -d download ]; then
    rm -rf download
fi

set -e
mkdir download
pushd download
cp ../deploy/emacs-jit*.deb .
wget https://github.com/d12frosted/elpa-mirror/archive/master.zip -O elpa-mirror-master.zip
git clone https://github.com/syl20bnr/spacemacs.git -b develop
popd

zipname="emacs-jit_$(date '+%Y%m%d').zip"
zip -qr $zipname download
cp $zipname /var/www/download/
