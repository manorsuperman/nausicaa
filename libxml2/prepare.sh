# prepare.sh --

set -x

(cd ..
    if test \
        configure -ot prepare.sh                                -o \
        configure -ot configure.ac                              -o \
        configure -ot aclocal.m4                                -o \
        configure -ot infrastructure/develstuff.autoconf        -o \
        configure -ot configuration/nausicaa.autoconf           -o \
        configure -ot configuration/libxml2-inspector.m4
        then
        autoconf
    fi)

../configure \
    --config-cache                                      \
    --with-abi=local-slackware                          \
    --enable-use-sudo                                   \
    --enable-ikarus                                     \
    --disable-larceny                                   \
    --enable-mosh                                       \
    --enable-ypsilon                                    \
    --enable-doc-ps                                     \
    --enable-time-tests                                 \
    "$@"

### end of file
