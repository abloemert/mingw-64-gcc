source test.sh

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
  --enable-shared \
  --prefix=${PREFIX} \
  --with-sysroot=${PREFIX}

echo "## Build binutils"
${MAKE} all
${MAKE} install
cd ${WORKSPACE}
