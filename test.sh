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

export CFLAGS="-s -O3 -Wno-expansion-to-defined -pipe"
export CXXFLAGS="${CFLAGS}"

echo "== Download mingw-w64 sources"
wget -q https://nav.dl.sourceforge.net/project/mingw-w64/mingw-w64/mingw-w64-release/mingw-w64-v9.0.0.tar.bz2
tar xjf mingw-w64-v9.0.0.tar.bz2

mkdir ${WORKSPACE}/build-mingw-w64
cd ${WORKSPACE}/build-mingw-w64

echo "== Configure mingw-w64"
../mingw-w64-v9.0.0/configure \
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

echo "== Build mingw-w64"
cd mingw-w64-headers
${MAKE} all
${MAKE} install
cd ${WORKSPACE}/build-mingw-w64

${MAKE} all
${MAKE} install
cd ${WORKSPACE}

echo "== Download gcc sources"
wget -q http://ftpmirror.gnu.org/gcc/gcc-8.4.0/gcc-8.4.0.tar.gz
tar xzf gcc-8.4.0.tar.gz
# todo: gmp, mpfr, mpc, isl

echo "== Prepare to build gcc"
cp -r ${DEST_DIR}/x86_64-w64-mingw32/lib ${DEST_DIR}/x86_64-w64-mingw32/lib64
cp -r ${DEST_DIR}/x86_64-w64-mingw32 ${DEST_DIR}/mingw
mkdir -p gcc-8.4.0/gcc/winsup/mingw
cp -r ${DEST_DIR}/x86_64-w64-mingw32/include gcc-8.4.0/gcc/winsup/mingw/include

mkdir build
cd build

echo "== Configure gcc"
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

echo "== Build gcc"
#${MAKE} bootstrap "CFLAGS=-g0 -O3" "CXXFLAGS=-g0 -O3" "CFLAGS_FOR_TARGET=-g0 -O3" "CXXFLAGS_FOR_TARGET=-g0 -O3" "BOOT_CFLAGS=-g0 -O3" "BOOT_CXXFLAGS=-g0 -O3"
#${MAKE} install

