#!/bin/bash


ARCH="x86_64"
YOCTO_IMAGE="core-image-minimal-qemux86.ext4"


qemu-system-"$ARCH" \
	-nographic \
	-kernel ../../arch/"$ARCH"/boot/bzImage \
	-drive file="$YOCTO_IMAGE",if=virtio,format=raw \
	-append "root=/dev/vda loglevel=15 console=hvc0 nokaslr" \
	-m 1024 \
	-s 

