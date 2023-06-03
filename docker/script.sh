#!/usr/bin/env bash
set -euo pipefail

build()
{
    VERSION=$1
    BITS=$2

    if [[ $BITS == "32" ]]
    then
        TOOLCHAIN=i686-w64-mingw32
    elif [[ $BITS == "64" ]]
    then
        TOOLCHAIN=x86_64-w64-mingw32
    fi
    DESTDIR="/build/$VERSION/$BITS"

    cd /vlc-$VERSION.0-win$BITS/*/sdk
    sed -i "s|^prefix=.*|prefix=$PWD|g" lib/pkgconfig/*.pc
    export PKG_CONFIG_PATH="${PWD}/lib/pkgconfig"
    if [ ! -f lib/vlccore.lib ]
    then
        echo "INPUT(libvlccore.lib)" > lib/vlccore.lib
    fi

    cd /repo
    make CC=$TOOLCHAIN-gcc LD=$TOOLCHAIN-ld OS=Windows
    $TOOLCHAIN-strip libnoop_video_filter_plugin.dll

    mkdir -p $DESTDIR
    cp libnoop_video_filter_plugin.dll $DESTDIR
    chmod 777 -R "/build/$VERSION"

    make clean OS=Windows

    cd /
}

build_opencv()
{
  echo "Building OpenCV plugin"
    VERSION=$1
    BITS=$2

    if [[ $BITS == "32" ]]
    then
        TOOLCHAIN=i686-w64-mingw32
    elif [[ $BITS == "64" ]]
    then
        TOOLCHAIN=x86_64-w64-mingw32
    fi
    DESTDIR="/build/$VERSION/$BITS"

    cd /vlc-$VERSION.0-win$BITS/*/sdk
    sed -i "s|^prefix=.*|prefix=$PWD|g" lib/pkgconfig/*.pc
    export PKG_CONFIG_PATH="${PWD}/lib/pkgconfig"
    if [ ! -f lib/vlccore.lib ]
    then
        echo "INPUT(libvlccore.lib)" > lib/vlccore.lib
    fi

    cd /repo
    make CC=$TOOLCHAIN-gcc LD=$TOOLCHAIN-ld OS=Windows --file Makefile_opencv
    $TOOLCHAIN-strip libopencv_video_filter_plugin.dll

    mkdir -p $DESTDIR
    cp libopencv_video_filter_plugin.dll $DESTDIR
    chmod 777 -R "/build/$VERSION"

    make clean OS=Windows

    cd /
}


if [[ "$1" == "all" ]]
then
    build 3.0 32
    build 3.0 64
    build_opencv 3.0 32
    build_opencv 3.0 64
else
    VERSION=$1
    BITS=$2

    if [ -z "$VERSION" ]
    then
        echo "Error: No VLC version was specified. Please specify '3.0' as the first argument to the script."
        exit 1
    fi

    if [[ "$VERSION" != "3.0" ]]
    then
        echo "Error: Incorrect VLC version was specified. Please specify '3.0' as the first argument to the script."
        exit 1
    fi

    if [ -z "$BITS" ]
    then
        echo "Error: No bitness was specified. Please specify either '32' or '64', as the second argument to the script."
        exit 1
    fi

    if [[ "$BITS" != "32" ]] && [[ "$BITS" != "64" ]]
    then
        echo "Error: Incorrect bitness was specified. Please specify either '32' or '64', as the second argument to the script."
        exit 1
    fi

    build $VERSION $BITS
fi
