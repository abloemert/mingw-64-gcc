# build mingw-64 + gcc

#set -u

# exit if a command fails
set -e

# print all commands
set -x

wget -q http://ftpmirror.gnu.org/gcc/gcc-8.4.0/gcc-8.4.0.tar.gz
tar xzf gcc-8.4.0.tar.gz

wget -q https://nav.dl.sourceforge.net/project/mingw-w64/mingw-w64/mingw-w64-release/mingw-w64-v9.0.0.tar.bz2
tar xjf mingw-w64-v9.0.0.tar.bz2

mkdir build-mingw-w64 dest
cd build-mingw-w64

../mingw-w64-v9.0.0/configure \
  --build=x86_64-w64-mingw32 \
  --host=x86_64-w64-mingw32 \
  --target=x86_64-w64-mingw32 \
  --disable-lib32 \
  --prefix=../dest/x86_64-w64-mingw32 \
  --with-sysroot=../dest/x86_64-w64-mingw32 \
  --enable-wildcard \
  --with-libraries=winpthreads \
  --disable-shared \
  || cat config.log
