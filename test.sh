echo "running from: $(pwd)"

# exit if a command fails
set -e

# print all commands
set -x

export PATH=$PATH:/mingw64/bin/

mkdir dest
export WORKSPACE=$(pwd)
export PREFIX=${WORKSPACE}/dest
export MAKE="make -s -j${NUMBER_OF_PROCESSORS} -O"

export CFLAGS="-s -O3 -Wno-expansion-to-defined -pipe"
export CXXFLAGS="${CFLAGS}"
export LDFLAGS="-Wl,-no-undefined" # fix shared builds

export TARGET="x86_64-w64-mingw32"
export BUILD=$TARGET
export HOST=$TARGET
