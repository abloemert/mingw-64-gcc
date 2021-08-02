# build mingw-64 + gcc

#set -u

# exit if a command fails
set -e

# print all commands
set -x

mkdir build-mingw-w64
cd build-mingw-w64

../mingw-w64-v9.0.0/configure \
  --build=x86_64-w64-mingw32 \
  --host=x86_64-w64-mingw32 \
  --target=x86_64-w64-mingw32 \
  --disable-lib32 \
  --prefix=/c/foobar \
  --with-sysroot=/c/foobar \
  --enable-wildcard \
  --with-libraries=winpthreads \
  --disable-shared
