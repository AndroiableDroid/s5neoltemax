#!/bin/sh

# kernel clean script by Shedrock v0.1

make clean
make mrproper
make distclean
rm -rf arch/arm64/boot/dts/*.dtb

