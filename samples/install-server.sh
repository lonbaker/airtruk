#!/bin/bash

if [ $# -ne 1 ] ; then
  echo "Usage: $0 <absolute-path-to-restore-image>"
  echo "Use INSTALL_DISK to specify target device. Defaults to /dev/sda."
  exit 1
fi

INSTALL_DISK=${INSTALL_DIS:-/dev/sda}
NEW_ROOT=/newroot

echo "Nuking existing partitions... CTRL+C to cancel, last shot (5 seconds)"
sleep 5
echo "dd if=/dev/zero of=${INSTALL_DISK} count=512"
dd if=/dev/zero of=${INSTALL_DISK} count=512

echo "Making base partition setup..."
echo "20GB Root + 16GB Swap + Remaining /webapp"
fdisk ${INSTALL_DISK} <<EOF
n
p
1
1
+20G
a
1
n
p
2

+16G
t
2
82
n
p
3


w
EOF
sleep 5

echo "Making filesystems..."
echo "Root: ext3"
mke2fs -j ${INSTALL_DISK}1
echo "Swap"
mkswap ${INSTALL_DISK}2
echo "/webapp: ext3"
mke2fs -j -m 0 ${INSTALL_DISK}3

echo "Mounting drives into ${NEW_ROOT}"
mkdir ${NEW_ROOT}
mount "${INSTALL_DISK}1" ${NEW_ROOT}

echo "Restoring from dump..."
cd ${NEW_ROOT}
restore -rvf $1

echo "Installing Grub to first partition on first hard disk..."
grub --batch --no-floppy <<EOF
root (hd0,0)
setup (hd0)
quit
EOF

echo "Fin."
