FROM ubuntu:20.04

WORKDIR /opt

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y git

# Clone emacs
RUN git clone --depth 1 git://git.savannah.gnu.org/emacs.git -b feature/native-comp emacs \
    && mv emacs/* .

# Install requirements for ppa below
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

# Install gcc-10 and deps from toolchain ppa
RUN add-apt-repository ppa:ubuntu-toolchain-r/ppa \
        && apt-get update -y \
        && apt-get install -y gcc-10 libgccjit0 libgccjit-10-dev

# Install all requirements to build
RUN sed -i 's/# deb-src/deb-src/' /etc/apt/sources.list \
    && apt-get update \
    && apt-get build-dep -y emacs

# Install further requirement for built below
RUN apt-get install -y libjansson4 libjansson-dev libwebkit2gtk-4.0-dev

# Build
ENV CC="gcc-10"
RUN ./autogen.sh && ./configure \
    --prefix "/usr/local/emacs-jit" \
    --with-nativecomp \
    --with-mailutils \
    --with-mailutils \
    --with-xwidgets \
    --with-modules \
    --with-imagemagick \
    --with-nativecomp \
    --with-json \
    CFLAGS="-O3 -mtune=native -march=native -fomit-frame-pointer"

ENV JOBS=4
RUN make -j ${JOBS}

# Create package
RUN EMACS_VERSION=$(sed -ne 's/AC_INIT(GNU Emacs, \([0-9.]\+\), .*/\1/p' configure.ac) \
    && make install prefix=/opt/emacs-jit_${EMACS_VERSION}/usr/local/emacs-jit \
    && cp /usr/lib/x86_64-linux-gnu/libgccjit* emacs-jit_${EMACS_VERSION}/usr/local/emacs-jit/lib \
    && mkdir emacs-jit_${EMACS_VERSION}/DEBIAN && echo "Package: emacs-jit\n\
Version: ${EMACS_VERSION}\n\
Section: base\n\
Priority: optional\n\
Architecture: amd64\n\
Depends: emacs, gcc-10\n\
Maintainer: Stefan Hackenberg <mail@stefan-hackenberg.de>\n\
Description: Emacs feature/native-comp build with\n\
 --with-nativecomp\n\
 --with-nativecomp\n\
 --with-mailutils\n\
 --with-mailutils\n\
 --with-xwidgets\n\
 --with-modules\n\
 --with-imagemagick\n\
 --with-nativecomp\n\
 --with-json\n\
 CFLAGS='-O3 -mtune=native -march=native -fomit-frame-pointer'" \
    >> emacs-jit_${EMACS_VERSION}/DEBIAN/control \
    && dpkg-deb --build emacs-jit_${EMACS_VERSION} \
    && mkdir /opt/deploy \
    && mv /opt/emacs-jit_*.deb /opt/deploy
