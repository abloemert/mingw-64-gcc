source test.sh

echo "## Download gdb sources"
wget -q https://ftp.gnu.org/gnu/gdb/gdb-8.3.tar.gz
tar xzf gdb-8.3.tar.gz

mkdir ${WORKSPACE}/build-gdb
cd ${WORKSPACE}/build-gdb

echo "## Configure gdb"
../gdb-8.3/configure \
  --build=${BUILD} \
  --host=${HOST} \
  --target=${TARGET} \
  --disable-nls `# Disable Native Language Support` \
  --enable-shared \
  --prefix=${PREFIX} \
  --with-sysroot=${PREFIX}
  
echo "## Build gdb"
${MAKE} all
${MAKE} install
cd ${WORKSPACE}
