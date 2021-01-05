FROM ubuntu:20.10
WORKDIR /opt
ENV DEBIAN_FRONTEND=noninteractive
ENV JOBS=5

RUN sed -i 's/# deb-src/deb-src/' /etc/apt/sources.list &&\
    apt-get update && apt-get install --yes --no-install-recommends  \
    build-essential \
    autoconf \
    git \
    pkg-config \
    libgnutls28-dev \
    libasound2-dev \
    libacl1-dev \
    libgtk-3-dev \
    libgpm-dev \
    liblockfile-dev \
    libm17n-dev \
    libotf-dev \
    libsystemd-dev \
    libjansson-dev \
    libgccjit-10-dev \
    libgif-dev \
    librsvg2-dev  \
    libxml2-dev \
    libxpm-dev \
    libtiff-dev \
    libjbig-dev \
    libncurses-dev\
    liblcms2-dev


# Clone emacs
RUN git clone --depth 1 git://git.savannah.gnu.org/emacs.git -b feature/native-comp emacs \
    && mv emacs/* .

# Build
ENV CC="gcc-10"
RUN ./autogen.sh && ./configure \
    --prefix "/usr/local" \
    --with-nativecomp \
    --with-json \
    --with-gnutls  \
    --with-rsvg  \
    --without-xwidgets \
    --without-toolkit-scroll-bars \
    --without-xaw3d \
    --without-makeinfo \
    --with-mailutils \
    CFLAGS="-O2 -pipe"

RUN make NATIVE_FULL_AOT=1 -j ${JOBS}

# Create package
RUN EMACS_VERSION=$(sed -ne 's/AC_INIT(GNU Emacs, \([0-9.]\+\), .*/\1/p' configure.ac) \
    && make install prefix=/opt/emacs-gcc_${EMACS_VERSION}/usr/local \
    && mkdir emacs-gcc_${EMACS_VERSION}/DEBIAN && echo "Package: emacs-gcc\n\
Version: ${EMACS_VERSION}\n\
Section: base\n\
Priority: optional\n\
Architecture: amd64\n\
Depends: libgif7, libotf0, libgccjit0, libm17n-0, libgtk-3-0, librsvg2-2, libtiff5, libjansson4, libacl1\n\
Maintainer: reichcv@gmail.com\n\
Description: Emacs with feature/native-comp\n\
    --with-nativecomp\n\
    --with-json\n\
    --with-gnutls\n\
    --with-rsvg\n\
    --without-xwidgets\n\
    --without-toolkit-scroll-bars\n\
    --without-xaw3d\n\
    --without-makeinfo\n\
    --with-mailutils\n\
 CFLAGS='-O2 -pipe'" \
    >> emacs-gcc_${EMACS_VERSION}/DEBIAN/control \
    && dpkg-deb --build emacs-gcc_${EMACS_VERSION} \
    && mkdir /opt/deploy \
    && mv /opt/emacs-gcc_*.deb /opt/deploy
