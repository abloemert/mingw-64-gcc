# build mingw-64 + gcc

echo "running from: $(pwd)"

# exit if a command fails
set -e

# print all commands
set -x

# probably not needed
#pacman -S --noconfirm --needed mingw-w64-x86_64-nasm

export PATH=$PATH:/mingw64/bin/

mkdir dest
WORKSPACE=$(pwd)
PREFIX=${WORKSPACE}/dest
MAKE="make -s -j${NUMBER_OF_PROCESSORS} -O"

export CFLAGS="-s -O3 -Wno-expansion-to-defined -pipe"
export CXXFLAGS="${CFLAGS}"
export LDFLAGS="-Wl,-no-undefined" # fix shared builds

TARGET="x86_64-w64-mingw32"
BUILD=$TARGET
HOST=$TARGET

echo "## Download binutils sources"
wget -q https://ftp.gnu.org/gnu/binutils/binutils-2.31.1.tar.bz2
tar xjf binutils-2.31.1.tar.bz2

mkdir ${WORKSPACE}/build-binutils
cd ${WORKSPACE}/build-binutils

echo "## Configure binutils"
../binutils-2.31.1/configure \
  --build=${BUILD} \
  --host=${HOST} \
  --target=${TARGET} \
  --disable-nls `# Disable Native Language Support` \
  --disable-multilib `# Only support 64-bit` \
  --prefix=${PREFIX}/binutils \
  --with-sysroot=${PREFIX}/binutils \

echo "## Build binutils"
${MAKE} all
${MAKE} install
cd ${WORKSPACE}

echo "## Download mingw-w64 sources"
wget -q https://nav.dl.sourceforge.net/project/mingw-w64/mingw-w64/mingw-w64-release/mingw-w64-v9.0.0.tar.bz2
tar xjf mingw-w64-v9.0.0.tar.bz2

mkdir ${WORKSPACE}/build-mingw-w64
cd ${WORKSPACE}/build-mingw-w64

echo "## Configure mingw-w64"
../mingw-w64-v9.0.0/configure --help

../mingw-w64-v9.0.0/configure \
  --build=${BUILD} \
  --host=${HOST} \
  --target=${TARGET} \
  --disable-lib32 \
  --prefix=${PREFIX}/${TARGET} \
  --with-sysroot=${PREFIX}/${TARGET} \
  --enable-wildcard \
  --with-libraries=winpthreads

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

ls -al src/

echo "## Prepare to build gcc"
cp -r ${PREFIX}/${TARGET}/lib ${PREFIX}/${TARGET}/lib64
cp -r ${PREFIX}/${TARGET} ${PREFIX}/mingw
mkdir -p src/gcc/winsup/mingw
cp -r ${PREFIX}/${TARGET}/include src/gcc/winsup/mingw/include

mkdir build
cd build

echo "## Configure gcc"
../src/configure \
  --prefix=${PREFIX} \
  --with-slibdir="${PREFIX}/lib" \
  --libdir="${PREFIX}/lib" \
  --build=${BUILD} \
  --host=${HOST} \
  --target=${TARGET} \
  --enable-default-pie \
  --enable-languages=c,c++ `# only build specific languages` \
  --enable-__cxa_atexit \
  --disable-libmudflap \
  --enable-libgomp `# Enable OpenMP` \
  --disable-libssp \
  --enable-libquadmath \
  --enable-libquadmath-support \
  --disable-libsanitizer `# Disable libsanitizer, no support on windows` \
  --enable-lto `# Enable link time optimization` \
  --enable-threads=posix `# Use winpthreads` \
  --enable-target-optspace \
  --enable-gold \
  --disable-nls `# Disable Native Language Support` \
  --disable-multilib `# Only support 64-bit` \
  --disable-bootstrap `# Speed up build` \
  --enable-long-long \
  --with-sysroot=${PREFIX} \
  --with-gxx-include-dir="${PREFIX}/include/c++/8.4.0" \
  --disable-libstdcxx-pch `# Not used and saves a lot of space` \
  --disable-libstdcxx-verbose `# Reduce generated executable size` \
  --disable-win32-registry \
  --with-tune=haswell `# Tune for Haswell by default`

echo "## Build gcc"
${MAKE} "CFLAGS=-g0 -O3" "CXXFLAGS=-g0 -O3" "CFLAGS_FOR_TARGET=-g0 -O3" "CXXFLAGS_FOR_TARGET=-g0 -O3" "BOOT_CFLAGS=-g0 -O3" "BOOT_CXXFLAGS=-g0 -O3"
${MAKE} install
