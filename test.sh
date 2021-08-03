# build mingw-64 + gcc

echo "running from: $(pwd)"

# exit if a command fails
set -e

# print all commands
set -x

# probably not needed, only nasm is not installed by default
#pacman -S --noconfirm --needed mingw-w64-x86_64-gcc mingw-w64-x86_64-cmake mingw-w64-x86_64-nasm

export PATH=$PATH:/mingw64/bin/

mkdir dest
WORKSPACE=$(pwd)
DEST_DIR=${WORKSPACE}/dest
MAKE="make -j${NUMBER_OF_PROCESSORS} -O"

wget -q https://nav.dl.sourceforge.net/project/mingw-w64/mingw-w64/mingw-w64-release/mingw-w64-v7.0.0.tar.bz2
tar xjf mingw-w64-v7.0.0.tar.bz2

mkdir ${WORKSPACE}/build-mingw-w64
cd ${WORKSPACE}/build-mingw-w64

../mingw-w64-v7.0.0/configure \
  --disable-dependency-tracking \
  --build=x86_64-w64-mingw32 \
  --host=x86_64-w64-mingw32 \
  --target=x86_64-w64-mingw32 \
  --disable-lib32 \
  --prefix=${DEST_DIR}/x86_64-w64-mingw32 \
  --with-sysroot=${DEST_DIR}/x86_64-w64-mingw32 \
  --enable-wildcard \
  --with-libraries=winpthreads \
  --disable-shared

cd mingw-w64-headers
${MAKE} all "CFLAGS=-s -O3"
${MAKE} install
cd ${WORKSPACE}/build-mingw-w64

${MAKE} all "CFLAGS=-s -O3 -Wno-expansion-to-defined"
${MAKE} install
cd ${WORKSPACE}

wget -q http://ftpmirror.gnu.org/gcc/gcc-8.4.0/gcc-8.4.0.tar.gz
tar xzf gcc-8.4.0.tar.gz
# todo: gmp, mpfr, mpc, isl

mkdir build
cd build

../gcc-8.4.0/configure \
  --enable-languages=c,c++ \
  --build=x86_64-w64-mingw32 \
  --host=x86_64-w64-mingw32 \
  --target=x86_64-w64-mingw32 \
  --disable-multilib \
  --prefix=$(pwd)/../dest \
  --with-sysroot=$(pwd)/../dest \
  --disable-libstdcxx-pch \
  --disable-libstdcxx-verbose \
  --disable-nls \
  --disable-shared \
  --disable-win32-registry \
  --enable-threads=posix \
  --enable-libgomp

${MAKE} bootstrap "CFLAGS=-g0 -O3" "CXXFLAGS=-g0 -O3" "CFLAGS_FOR_TARGET=-g0 -O3" "CXXFLAGS_FOR_TARGET=-g0 -O3" "BOOT_CFLAGS=-g0 -O3" "BOOT_CXXFLAGS=-g0 -O3"
${MAKE} install

