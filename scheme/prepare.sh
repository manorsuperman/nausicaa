# prepare.sh --

set -x

(cd ..
    if test \
        configure.ac -nt configure -o \
        ../infrastructure/aclocal.m4 -nt configure
        then
        autoconf
    fi)

../configure \
    --enable-fasl               \
    --enable-ikarus             \
    --enable-larceny            \
    --enable-ypsilon            \
    --enable-binfmt             \
    "$@"

#    --enable-mosh               \


### end of file