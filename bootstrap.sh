# Run this in a path you don't care about, things may get deleted!
VERSION="1.0"
BUILD="betable3"

set -e -x
ORIGPWD="$(pwd)"
TMP="$(mktemp -d)"
cd $TMP
trap "rm -rf \"$TMP\"" EXIT INT QUIT TERM

git clone https://github.com/inconshreveable/ngrok
cd ngrok
git checkout -b head 76ef59fe5d334fc989e8409948d0c357b2750147

patch -p1 < "$ORIGPWD/patches/host-xss.patch"

make

mkdir "rootfs"
mkdir "rootfs/etc"
mkdir "rootfs/usr"
cp -r "bin" "rootfs/usr/bin"

rm -f "$ORIGPWD/ngrok_${VERSION}-${BUILD}_amd64.deb"

fakeroot fpm -C "rootfs" \
             -m "Max Furman <max@betable.com>" \
             -n "ngrok" -v "$VERSION-$BUILD" \
             -p "$ORIGPWD/ngrok_${VERSION}-${BUILD}_amd64.deb" \
             -s "dir" -t "deb" \
             "etc" "usr"
