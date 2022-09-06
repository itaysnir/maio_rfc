#!/bin/bash

set -euxo pipefail


ARCH="x86_64"

KDIR="$HOME/projects/maio_rfc"
BZIMAGE="${KDIR}/arch/${ARCH}/boot/bzImage"
DEBIAN_SUITE="jessie"
DEBIAN_FS="${KDIR}/tools/itay/jessie"
DEBIAN_IMG="${DEBIAN_FS}.img"
MAIO_FILES="${KDIR}/tools/lib/maio"

if [ $# -ge 1 ] && [ "$1" = "build-fs" ]; then
	if [ ! -d ${DEBIAN_FS} ]; then
		sudo mkdir -p ${DEBIAN_FS}
		sudo debootstrap --include=openssh-server,build-essential \
			${DEBIAN_SUITE} ${DEBIAN_FS}

		sudo sed -i '/^root/ { s/:x:/::/ }' ${DEBIAN_FS}/etc/passwd
		echo 'V0:23:respawn:/sbin/getty 115200 hvc0' | sudo tee -a ${DEBIAN_FS}/etc/inittab
		printf '\nauto eth0\niface eth0 inet dhcp\n' | sudo tee -a ${DEBIAN_FS}/etc/network/interfaces
		sudo rm -rf ${DEBIAN_FS}/root/.ssh/
		sudo mkdir ${DEBIAN_FS}/root/.ssh/
		cat ~/.ssh/id_?sa.pub | sudo tee ${DEBIAN_FS}/root/.ssh/authorized_keys

		sudo cp -r ${MAIO_FILES} ${DEBIAN_FS}/root/
	fi


	dd if=/dev/zero of=${DEBIAN_IMG} bs=1M seek=4095 count=1
	mkfs.ext4 -F ${DEBIAN_IMG}
	sudo mkdir -p /mnt/jessie
	sudo mount -o loop ${DEBIAN_IMG} /mnt/jessie
	sudo cp -a ${DEBIAN_FS}/. /mnt/jessie/.
	sudo umount /mnt/jessie
	sudo rm -rf /mnt/jessie
fi

#	-nographic \
#	-append "root=/dev/vda loglevel=15 console=hvc0 nokaslr" \

qemu-system-"$ARCH" \
	-kernel ${BZIMAGE} \
	-drive file=${DEBIAN_IMG},if=virtio,format=raw \
	-append "root=/dev/vda rw nokaslr" \
	-m 1024 \
	-s \
	-net nic,model=virtio,macaddr=52:54:00:12:34:56 \
	-net user,hostfwd=tcp:127.0.0.1:4444-:22

