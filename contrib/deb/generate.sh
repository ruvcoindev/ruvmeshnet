#!/bin/sh

# This is a lazy script to create a .deb for Debian/Ubuntu. It installs
# ruvmeshnet and enables it in systemd. You can give it the PKGARCH= argument
# i.e. PKGARCH=i386 sh contrib/deb/generate.sh

if [ `pwd` != `git rev-parse --show-toplevel` ]
then
  echo "You should run this script from the top-level directory of the git repo"
  exit 1
fi

PKGBRANCH=$(basename `git name-rev --name-only HEAD`)
PKGNAME=$(sh contrib/semver/name.sh)
PKGVERSION=$(sh contrib/semver/version.sh --bare)
PKGARCH=${PKGARCH-amd64}
PKGFILE=$PKGNAME-$PKGVERSION-$PKGARCH.deb
PKGREPLACES=ruvmeshnet

if [ $PKGBRANCH = "master" ]; then
  PKGREPLACES=ruvmeshnet-develop
fi

GOLDFLAGS="-X github.com/ruvcoindev/ruvmeshnet/src/config.defaultConfig=/etc/ruvmeshnet/ruvmeshnet.conf"
GOLDFLAGS="${GOLDFLAGS} -X github.com/ruvcoindev/ruvmeshnet/src/config.defaultAdminListen=unix:///var/run/ruvmeshnet/ruvmeshnet.sock"

if [ $PKGARCH = "amd64" ]; then GOARCH=amd64 GOOS=linux ./build -l "${GOLDFLAGS}"
elif [ $PKGARCH = "i386" ]; then GOARCH=386 GOOS=linux ./build -l "${GOLDFLAGS}"
elif [ $PKGARCH = "mipsel" ]; then GOARCH=mipsle GOOS=linux ./build -l "${GOLDFLAGS}"
elif [ $PKGARCH = "mips" ]; then GOARCH=mips64 GOOS=linux ./build -l "${GOLDFLAGS}"
elif [ $PKGARCH = "armhf" ]; then GOARCH=arm GOOS=linux GOARM=6 ./build -l "${GOLDFLAGS}"
elif [ $PKGARCH = "arm64" ]; then GOARCH=arm64 GOOS=linux ./build -l "${GOLDFLAGS}"
elif [ $PKGARCH = "armel" ]; then GOARCH=arm GOOS=linux GOARM=5 ./build -l "${GOLDFLAGS}"
else
  echo "Specify PKGARCH=amd64,i386,mips,mipsel,armhf,arm64,armel"
  exit 1
fi

echo "Building $PKGFILE"

mkdir -p /tmp/$PKGNAME/
mkdir -p /tmp/$PKGNAME/debian/
mkdir -p /tmp/$PKGNAME/usr/bin/
mkdir -p /tmp/$PKGNAME/lib/systemd/system/

cat > /tmp/$PKGNAME/debian/changelog << EOF
Please see github.com/ruvcoindev/ruvmeshnet/
EOF
echo 9 > /tmp/$PKGNAME/debian/compat
cat > /tmp/$PKGNAME/debian/control << EOF
Package: $PKGNAME
Version: $PKGVERSION
Section: contrib/net
Priority: extra
Architecture: $PKGARCH
Replaces: $PKGREPLACES
Conflicts: $PKGREPLACES
Maintainer: Neil Alexander <neilalexander@users.noreply.github.com> & ruvcoindev
Description: RuvChain Mesh Network
 Ruvmeshnet is an early-stage implementation of a fully end-to-end encrypted IPv6
 network. It is lightweight, self-arranging, supported on multiple platforms and
 allows pretty much any IPv6-capable application to communicate securely with
 other Ruvmeshnet nodes.
EOF
cat > /tmp/$PKGNAME/debian/copyright << EOF
Please see https://github.com/ruvcoindev/ruvmeshnet/
EOF
cat > /tmp/$PKGNAME/debian/docs << EOF
Please see https://github.com/ruvcoindev/ruvmeshnet/
EOF
cat > /tmp/$PKGNAME/debian/install << EOF
usr/bin/ruvmeshnet usr/bin
usr/bin/ruvmeshnetctl usr/bin
lib/systemd/system/*.service lib/systemd/system
EOF
cat > /tmp/$PKGNAME/debian/postinst << EOF
#!/bin/sh

systemctl daemon-reload

if ! getent group ruvmeshnet 2>&1 > /dev/null; then
  groupadd --system --force ruvmeshnet
fi

if [ ! -d /etc/ruvmeshnet ];
then
    mkdir -p /etc/ruvmeshnet
    chown root:ruvmeshnet /etc/ruvmeshnet
    chmod 750 /etc/ruvmeshnet
fi

if [ ! -f /etc/ruvmeshnet/ruvmeshnet.conf ];
then
    test -f /etc/ruvmeshnet.conf && mv /etc/ruvmeshnet.conf /etc/ruvmeshnet/ruvmeshnet.conf
fi

if [ -f /etc/ruvmeshnet/ruvmeshnet.conf ];
then
  mkdir -p /var/backups
  echo "Backing up configuration file to /var/backups/ruvmeshnet.conf.`date +%Y%m%d`"
  cp /etc/ruvmeshnet/ruvmeshnet.conf /var/backups/ruvmeshnet.conf.`date +%Y%m%d`

  echo "Normalising and updating /etc/ruvmeshnet/ruvmeshnet.conf"
  /usr/bin/ruvmeshnet -useconf -normaliseconf < /var/backups/ruvmeshnet.conf.`date +%Y%m%d` > /etc/ruvmeshnet/ruvmeshnet.conf
  
  chown root:ruvmeshnet /etc/ruvmeshnet/ruvmeshnet.conf
  chmod 640 /etc/ruvmeshnet/ruvmeshnet.conf
else
  echo "Generating initial configuration file /etc/ruvmeshnet/ruvmeshnet.conf"
  /usr/bin/ruvmeshnet -genconf > /etc/ruvmeshnet/ruvmeshnet.conf

  chown root:ruvmeshnet /etc/ruvmeshnet/ruvmeshnet.conf
  chmod 640 /etc/ruvmeshnet/ruvmeshnet.conf
fi

systemctl enable ruvmeshnet
systemctl restart ruvmeshnet

exit 0
EOF
cat > /tmp/$PKGNAME/debian/prerm << EOF
#!/bin/sh
if command -v systemctl >/dev/null; then
  if systemctl is-active --quiet ruvmeshnet; then
    systemctl stop ruvmeshnet || true
  fi
  systemctl disable ruvmeshnet || true
fi
EOF

cp ruvmeshnet /tmp/$PKGNAME/usr/bin/
cp ruvmeshnetctl /tmp/$PKGNAME/usr/bin/
cp contrib/systemd/ruvmeshnet-default-config.service.debian /tmp/$PKGNAME/lib/systemd/system/ruvmeshnet-default-config.service
cp contrib/systemd/ruvmeshnet.service.debian /tmp/$PKGNAME/lib/systemd/system/ruvmeshnet.service

tar --no-xattrs -czvf /tmp/$PKGNAME/data.tar.gz -C /tmp/$PKGNAME/ \
  usr/bin/ruvmeshnet usr/bin/ruvmeshnetctl \
  lib/systemd/system/ruvmeshnet.service \
  lib/systemd/system/ruvmeshnet-default-config.service
tar --no-xattrs -czvf /tmp/$PKGNAME/control.tar.gz -C /tmp/$PKGNAME/debian .
echo 2.0 > /tmp/$PKGNAME/debian-binary

ar -r $PKGFILE \
  /tmp/$PKGNAME/debian-binary \
  /tmp/$PKGNAME/control.tar.gz \
  /tmp/$PKGNAME/data.tar.gz

rm -rf /tmp/$PKGNAME
