#!/bin/bash

OPENSSL_VERSION="3.3.1"
OPENSSL_VERSION_SHORT="3"
NUM_CORES=$(sysctl -n hw.logicalcpu)

wget https://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz
tar -xvzf openssl-$OPENSSL_VERSION.tar.gz -C .
mv openssl-$OPENSSL_VERSION openssl_arm64
cp -r openssl_arm64 openssl_x86_64

cd openssl_arm64
./Configure shared darwin64-arm64-cc
make -j$NUM_CORES
cd ../

cd openssl_x86_64
./Configure shared darwin64-x86_64-cc 
make -j$NUM_CORES
cd ../


lipo -create openssl_arm64/libcrypto.$OPENSSL_VERSION_SHORT.dylib \
    openssl_x86_64/libcrypto.$OPENSSL_VERSION_SHORT.dylib \
    -output libcrypto.$OPENSSL_VERSION_SHORT.dylib
lipo -create openssl_arm64/libssl.$OPENSSL_VERSION_SHORT.dylib \
    openssl_x86_64/libssl.$OPENSSL_VERSION_SHORT.dylib \
    -output libssl.$OPENSSL_VERSION_SHORT.dylib
