#!/bin/bash


ARCH="i386"


qemu-system-"$ARCH" \
	-kernel arch/"$ARCH"/boot/bzImage \
	-nographic \
	-append "console=ttyS0 nokaslr" \
	-initrd ramdisk.img \
	-m 512 \
	--enable-kvm \
	-cpu host \
	-s -S &
