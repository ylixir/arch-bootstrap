#!/bin/bash

NETWORKING_PACKAGES=`cat networking\ packages.txt`
rm -rf archnexus
rm -rf archroot

mkdir -p archnexus/rom
mkdir -p archnexus/root_dir
mkdir -p archnexus/post_intall
mkdir archroot
cp manifest.txt archnexus/
cp rom_info.txt archnexus/root_dir

./arch-bootstrap.sh archroot

mkdir -p archroot/dev/pts
mount -t proc proc archroot/proc
mount -t sysfs sys archroot/sys
mount --bind /dev archroot/dev
mount -t devpts devpts -o mode=620,gid=5 archroot/dev/pts

#setup the archnexus repo and device specific packages
chroot archroot pacman --noconfirm -U https://github.com/ylixir/aur/releases/download/repo/archnexus-repo-1-1-any.pkg.tar.xz
chroot archroot pacman --noconfirm -Syu linux-grouper-git
chroot archroot pacman -Scc
chroot archroot pacman --noconfirm -Sw $NETWORKING_PACKAGES
#enable the serial connection
chroot archroot ln -s "/usr/lib/systemd/system/getty@.service" "/etc/systemd/system/getty.target.wants/getty@ttyGS0.service"
echo >> "archroot/etc/securetty"
echo "# Allow root on serial console" >> "archroot/etc/securetty"
echo "ttyGS0" >> "archroot/etc/securetty"

sleep 5
umount archroot/dev/pts
umount archroot/dev
umount archroot/sys
umount archroot/proc

cd archroot
tar -czf ../archnexus/rom/root.tar.gz ./
cd ../archnexus
zip -r -0 ../archnexus.mrom ./ -x \*~
