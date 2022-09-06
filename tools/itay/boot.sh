#!/bin/bash

set -euxo pipefail


ARCH="x86_64"

DEBIAN_SUITE="jessie"
DEBIAN_FS="$HOME/projects/maio_rfc/tools/itay/jessie"
DEBIAN_IMG="${DEBIAN_FS}.img"


if [ $# -ge 1 ] && [ "$1" = "build-fs" ]; then
	sudo rm -rf ${DEBIAN_FS}
	sudo mkdir -p ${DEBIAN_FS}
	sudo debootstrap --include=openssh-server \
		--include=gcc-4.9-base \
		${DEBIAN_SUITE} ${DEBIAN_FS}


	sudo sed -i '/^root/ { s/:x:/::/ }' ${DEBIAN_FS}/etc/passwd
	echo 'V0:23:respawn:/sbin/getty 115200 hvc0' | sudo tee -a ${DEBIAN_FS}/etc/inittab
	printf '\nauto eth0\niface eth0 inet dhcp\n' | sudo tee -a ${DEBIAN_FS}/etc/network/interfaces
	sudo rm -rf ${DEBIAN_FS}/root/.ssh/
	sudo mkdir ${DEBIAN_FS}/root/.ssh/
	cat ~/.ssh/id_?sa.pub | sudo tee ${DEBIAN_FS}/root/.ssh/authorized_keys

	dd if=/dev/zero of=${DEBIAN_IMG} bs=1M seek=4095 count=1
	mkfs.ext4 -F ${DEBIAN_IMG}
	sudo mkdir -p /mnt/jessie
	sudo mount -o loop ${DEBIAN_IMG} /mnt/jessie
	sudo cp -a ${DEBIAN_FS}/. /mnt/jessie/.
	sudo umount /mnt/jessie
fi

#	-nographic \
#	-append "root=/dev/vda loglevel=15 console=hvc0 nokaslr" \

qemu-system-"$ARCH" \
	-kernel ../../arch/"$ARCH"/boot/bzImage \
	-drive file=${DEBIAN_IMG},if=virtio,format=raw \
	-append "root=/dev/vda nokaslr" \
	-m 1024 \
	-s

