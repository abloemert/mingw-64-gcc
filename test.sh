echo "running from: $(pwd)"

# exit if a command fails
set -e

# print all commands
set -x

wget -q https://sourceforge.net/projects/tkimg/files/tkimg/1.4/tkimg%201.4.13/Img-1.4.13-Source.tar.gz

tar xzf Img-1.4.13-Source.tar.gz

export PREFIX=$(pwd)

cd Img-1.4.13

./configure --prefix=${PREFIX}        \
            --with-tcl=${PREFIX}/lib  \
            --with-tk=${PREFIX}/lib
make -j${CPU_COUNT} ${VERBOSE_AT}
make install
