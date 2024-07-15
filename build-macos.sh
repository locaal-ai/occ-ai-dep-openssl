#!/bin/bash

# Exit on error and print each command
set -e
set -x

# Build OpenSSL for macOS

OPENSSL_VERSION="3.3.1"
OPENSSL_VERSION_SHORT="3"
NUM_CORES=$(sysctl -n hw.logicalcpu)

wget https://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz
tar -xvzf openssl-$OPENSSL_VERSION.tar.gz -C .
mv openssl-$OPENSSL_VERSION openssl_arm64
cp -r openssl_arm64 openssl_x86_64

cd openssl_arm64
./Configure shared --prefix="$(pwd)/release" \
    --openssldir="$(pwd)/release" \
    darwin64-arm64-cc
make -j$NUM_CORES
# install into the current directory
make install_sw
cd ../

cd openssl_x86_64
./Configure shared --prefix="$(pwd)/release" \
    --openssldir="$(pwd)/release" \
    darwin64-x86_64-cc 
make -j$NUM_CORES
# install into the current directory
make install_sw
cd ../

mkdir release

# shared libraries
lipo -create openssl_arm64/release/lib/libcrypto.$OPENSSL_VERSION_SHORT.dylib \
    openssl_x86_64/release/lib/libcrypto.$OPENSSL_VERSION_SHORT.dylib \
    -output release/lib/libcrypto.$OPENSSL_VERSION_SHORT.dylib
lipo -create openssl_arm64/release/lib/libssl.$OPENSSL_VERSION_SHORT.dylib \
    openssl_x86_64/release/lib/libssl.$OPENSSL_VERSION_SHORT.dylib \
    -output release/lib/libssl.$OPENSSL_VERSION_SHORT.dylib

# static libraries
lipo -create openssl_arm64/release/lib/libcrypto.a \
    openssl_x86_64/release/lib/libcrypto.a \
    -output release/lib/libcrypto.a
lipo -create openssl_arm64/release/lib/libssl.a \
    openssl_x86_64/release/lib/libssl.a \
    -output release/lib/libssl.a

cp -r openssl_arm64/release/include release/include

# create a tarball
tar -czvf openssl-$OPENSSL_VERSION-macos.tar.gz release
