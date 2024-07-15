#!/bin/bash

OPENSSL_VERSION="3.3.1"

wget https://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz
tar -xvzf openssl-$OPENSSL_VERSION.tar.gz -C .
mv openssl-$OPENSSL_VERSION openssl_arm64
cp -r openssl_arm64 openssl_x86_64

cd openssl_arm64
./Configure shared darwin64-arm64-cc
make
cd ../

cd openssl_x86_64
./Configure shared darwin64-x86_64-cc 
make
cd ../

lipo -create openssl_arm64/libcrypto.$OPENSSL_VERSION.dylib openssl_x86_64/libcrypto.$OPENSSL_VERSION.dylib -output libcrypto.$OPENSSL_VERSION.dylib
lipo -create openssl_arm64/libssl.$OPENSSL_VERSION.dylib openssl_x86_64/libssl.$OPENSSL_VERSION.dylib -output libssl.$OPENSSL_VERSION.dylib
