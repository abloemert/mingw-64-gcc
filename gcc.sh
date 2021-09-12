source test.sh

echo "## Download mingw-w64 sources"
MINGW_VERSION=7.0.0
wget -q https://nav.dl.sourceforge.net/project/mingw-w64/mingw-w64/mingw-w64-release/mingw-w64-v${MINGW_VERSION}.tar.bz2
tar xjf mingw-w64-v${MINGW_VERSION}.tar.bz2

mkdir ${WORKSPACE}/build-mingw-w64
cd ${WORKSPACE}/build-mingw-w64

echo "## Configure mingw-w64"
../mingw-w64-v${MINGW_VERSION}/configure --help=recursive

../mingw-w64-v${MINGW_VERSION}/configure \
  --build=${BUILD} \
  --host=${HOST} \
  --target=${TARGET} \
  --disable-lib32 \
  --enable-shared \
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

mkdir build
cd build

# --enable-host-shared

echo "## Configure gcc"
../src/configure \
  --prefix=${PREFIX} \
  --build=${BUILD} \
  --host=${HOST} \
  --target=${TARGET} \
  --enable-shared \
  --enable-languages=c,c++ `# only build specific languages` \
  --enable-libgomp `# Enable OpenMP` \
  --enable-threads=posix `# Use winpthreads` \
  --enable-target-optspace \
  --disable-nls `# Disable Native Language Support` \
  --disable-multilib `# Only support 64-bit` \
  --with-sysroot=${PREFIX} \
  --disable-libstdcxx-pch `# Not used and saves a lot of space` \
  --disable-libstdcxx-verbose `# Reduce generated executable size` \
  --disable-win32-registry \
  --with-arch=nocona \
  --with-tune=core2

echo "## Build gcc"
${MAKE} bootstrap2-lean
${MAKE} install-strip
