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
PREFIX=${WORKSPACE}/dest
MAKE="make -s -j${NUMBER_OF_PROCESSORS} -O"

export CFLAGS="-s -O3 -Wno-expansion-to-defined -pipe"
export CXXFLAGS="${CFLAGS}"

echo "## Download mingw-w64 sources"
wget -q https://nav.dl.sourceforge.net/project/mingw-w64/mingw-w64/mingw-w64-release/mingw-w64-v6.0.0.tar.bz2
tar xjf mingw-w64-v6.0.0.tar.bz2

mkdir ${WORKSPACE}/build-mingw-w64
cd ${WORKSPACE}/build-mingw-w64

echo "## Configure mingw-w64"
../mingw-w64-v6.0.0/configure \
  --build=x86_64-w64-mingw32 \
  --host=x86_64-w64-mingw32 \
  --target=x86_64-w64-mingw32 \
  --disable-lib32 \
  --prefix=${PREFIX}/x86_64-w64-mingw32 \
  --with-sysroot=${PREFIX}/x86_64-w64-mingw32 \
  --enable-wildcard \
  --with-libraries=winpthreads \
  --disable-shared

echo "## Build mingw-w64"
cd mingw-w64-headers
${MAKE} all
${MAKE} install
cd ${WORKSPACE}/build-mingw-w64

${MAKE} all
${MAKE} install
cd ${WORKSPACE}

echo "## Download gcc sources and its dependencies"
wget -q http://ftpmirror.gnu.org/gcc/gcc-8.4.0/gcc-8.4.0.tar.gz
tar xzf gcc-8.4.0.tar.gz
wget -q http://ftpmirror.gnu.org/mpfr/mpfr-4.0.2.tar.gz
tar xzf mpfr-4.0.2.tar.gz
wget -q http://ftpmirror.gnu.org/gmp/gmp-6.1.2.tar.bz2
tar xjf gmp-6.1.2.tar.bz2
wget -q http://ftpmirror.gnu.org/mpc/mpc-1.1.0.tar.gz
tar xzf mpc-1.1.0.tar.gz
wget -q https://gcc.gnu.org/pub/gcc/infrastructure/isl-0.18.tar.bz2
tar xjf isl-0.18.tar.bz2

mv gcc-8.4.0 src
mv mpfr-4.0.2 src/mpfr
mv gmp-6.1.2 src/gmp
mv mpc-1.1.0 src/mpc
mv isl-0.18 src/isl

echo "## Prepare to build gcc"
cp -r ${PREFIX}/x86_64-w64-mingw32/lib ${PREFIX}/x86_64-w64-mingw32/lib64
cp -r ${PREFIX}/x86_64-w64-mingw32 ${PREFIX}/mingw
mkdir -p src/gcc/winsup/mingw
cp -r ${PREFIX}/x86_64-w64-mingw32/include src/gcc/winsup/mingw/include

mkdir build
cd build

echo "## Configure gcc"
../src/configure \
  --prefix=${PREFIX} \
  --with-slibdir="${PREFIX}/lib" \
  --libdir="${PREFIX}/lib" \
  --build=x86_64-w64-mingw32 \
  --host=x86_64-w64-mingw32 \
  --target=x86_64-w64-mingw32 \
  --enable-default-pie \
  --enable-languages=c,c++,fortran,objc,obj-c++ \
  --enable-__cxa_atexit \
  --disable-libmudflap \
  --enable-libgomp \
  --disable-libssp \
  --enable-libquadmath \
  --enable-libquadmath-support \
  --enable-libsanitizer \
  --enable-lto \
  --enable-threads=posix \
  --enable-target-optspace \
  --enable-plugin \
  --enable-gold \
  --disable-nls \
  --disable-bootstrap \
  --disable-multilib \
  --enable-long-long \
  --enable-default-pie \
  --with-sysroot=${PREFIX} \
  --disable-libstdcxx-pch \
  --disable-libstdcxx-verbose \
  --disable-win32-registry \
  --with-tune=haswell

#  --with-sysroot=${PREFIX}/${TARGET}/sysroot
#  --with-build-sysroot=${BUILD_PREFIX}/${TARGET}/sysroot
#  --with-gxx-include-dir="${PREFIX}/${TARGET}/include/c++/${gcc_version}"


echo "## Build gcc"
${MAKE} "CFLAGS=-g0 -O3" "CXXFLAGS=-g0 -O3" "CFLAGS_FOR_TARGET=-g0 -O3" "CXXFLAGS_FOR_TARGET=-g0 -O3" "BOOT_CFLAGS=-g0 -O3" "BOOT_CXXFLAGS=-g0 -O3"
${MAKE} install
