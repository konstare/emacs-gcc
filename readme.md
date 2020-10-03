<!-- -*- fill-column: 80; -*- -->
# emacs-jit

## Summary
This repository shows a Dockerfile to create a deb package containing a build
from head of emacs' repository branch `feature/native-comp`.

Emacs source can be downloaded from <git://git.savannah.gnu.org/emacs.git>

## Compile flags
The [Dockerfile](./Dockerfile) compiles emacs with the following settings:
- `--with-nativecomp`
- `--with-mailutils`
- `--with-mailutils`
- `--with-xwidgets`
- `--with-modules`
- `--with-imagemagick`
- `--with-nativecomp`
- `--with-json`
- `CFLAGS="-O3 -mtune=x86-64 -march=x86-64 -fomit-frame-pointer"`

## Libgccjit

As of 2020-10-03 archive.ubuntu.com serves the package `libgccjit0` in version
`10-20200411-0ubuntu1`. I don't know why but it does not work; neither to
compile emacs nor to run it. Therefore the appropriate packages are taken from
`ppa:ubuntu-toolchain-r/ppa` where its version is `10.2.0-5ubuntu1~20.04`.
To be able to stay with a default Ubuntu installation the generated deb contains
the two necessary files. To run emacs-jit you have to setup library path
correctly:
```bash
export LD_LIBRARY_PATH=/usr/local/emacs-jit/lib
/usr/local/emacs-jit/bin/emacs
```
