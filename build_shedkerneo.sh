#!/bin/sh

# kernel build script by Shedrock v0.7

####################################### VARIABLES #######################################

ARCH=arm64
SUBARCH=arm64
#CROSS_COMPILE=/home/buildtest/ndk/android-ndk-r14b/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64/
CROSS_COMPILE=/home/wilmans2m/toolchains-google/bin/aarch64-linux-android-
#CROSS_COMPILE=./toolchains-google/bin/aarch64-linux-android-
#CROSS_COMPILE=/home/wilmans2m/toolchains/google/bin/aarch64-linux-android-
#CROSS_COMPILE=/home/wilmans2m/toolchains/ndk/bin/aarch64-linux-android-
#CROSS_COMPILE=/home/wilmans2m/toolchains/ndkr78/bin/aarch64-linux-android-
#CROSS_COMPILE=/home/wilmans2m/toolchains/gccm49/bin/aarch64-linux-android-
#CROSS_COMPILE=/home/wilmans2m/toolchains/sabermod49/bin/aarch64-linux-android-
#CROSS_COMPILE=/home/wilmans2m/toolchains/ubertc/4.9.4/bin/aarch64-linux-android-
#CROSS_COMPILE=/home/wilmans2m/toolchains/ubertc/5.3.1/bin/aarch64-linux-android-
#CROSS_COMPILE=/home/wilmans2m/toolchains/ubertc/6.0/bin/aarch64-linux-android-
#CROSS_COMPILE=/home/wilmans2m/toolchains/linaro/4.9.4-2017.01/aarch64/bin/aarch64-linux-android-
#CROSS_COMPILE=/home/wilmans2m/toolchains/linaro/4.9-2016.02/aarch64/bin/aarch64-linux-android-
#CROSS_COMPILE=/home/wilmans2m/toolchains/linaro/5.1-2015.08/aarch64/bin/aarch64-linux-android-
#CROSS_COMPILE=/home/wilmans2m/toolchains/linaro/5.2-2015.11/aarch64/bin/aarch64-linux-android-
#CROSS_COMPILE=/home/wilmans2m/toolchains/linaro/5.2-2015.11.1/aarch64/bin/aarch64-linux-android-
#CROSS_COMPILE=/home/wilmans2m/toolchains/linaro/5.2-2015.11.2/aarch64/bin/aarch64-linux-android-
#CROSS_COMPILE=/home/wilmans2m/toolchains/linaro/5.3.1-2016.05/aarch64/bin/aarch64-linux-android-
#CROSS_COMPILE=/home/wilmans2m/toolchains/linaro/4.9.4-2017.01/aarch64/bin/aarch64-linux-android-
#CROSS_COMPILE=/home/wilmans2m/toolchains/linaro/5.3-2016.02/aarch64/bin/aarch64-linux-android-
#CROSS_COMPILE=/home/wilmans2m/toolchains/linaro/5.4.1-2017.01/aarch64/bin/aarch64-linux-android-
#CROSS_COMPILE=/home/wilmans2m/toolchains/linaro/6.1.1-2016.08/aarch64/bin/aarch64-linux-android-
#CROSS_COMPILE=/home/wilmans2m/toolchains/linaro/6.2.1-2016.11/aarch64/bin/aarch64-linux-android-
#CROSS_COMPILE=/home/wilmans2m/toolchains/linaro/6.3.1-2017.02/aarch64/bin/aarch64-linux-android-

BUILD_COMMAND=$1
RDIR=$(pwd)
RAMD=$RDIR/ramdisk
OUTDIR=$RDIR/arch/$ARCH/boot
mkdir -p $RDIR/out
BUILTDIR=$RDIR/out
DTSDIR=$RDIR/arch/$ARCH/boot/dts
INCDIR=$RDIR/include
KERN=out/Image
RAM=out/ramdisk.gz
DTIMG=out/dt.img
#KERNOUT=out/boot.img
KERNOUT=$RDIR/boot.img
BASE=0x10000000
KOFF=0x00008000 
ROFF=0x01000000 
TOFF=0x00000100 
PS=2048
CMDL="console=ttySAC1"
BRD=SYSMAGIC000KU
#KERNEL_DEFCONFIG=exynos7580-s5neolte_defconfig
KERNEL_DEFCONFIG=s5neolte_defconfig
#KERNEL_DEFCONFIG=s5neolte_00_defconfig

####################################### COMPILE FUNCTIONS #######################################

FUNC_BUILD_KERNEL()
{
	echo ""
        echo "=============================================="
        echo "START : FUNC_BUILD_KERNEL"
        echo "=============================================="
        echo ""
        echo "build common config="$KERNEL_DEFCONFIG ""

	make ARCH=$ARCH $KERNEL_DEFCONFIG

	make -j$NUMBEROFCPUS LOCALVERSION="#shedkerneo.b5"
	
	mv -f $OUTDIR/Image $BUILTDIR/Image	

	echo ""
	echo "================================="
	echo "END   : FUNC_BUILD_KERNEL"
	echo "================================="
	echo ""
}

FUNC_BUILD_DTIMAGE()
{
	echo ""
        echo "=============================================="
        echo "START : FUNC_BUILD_DTIMAGE"
        echo "=============================================="
        echo ""
	
	if [ -e $BUILTDIR/Image ]; then
	echo "--- Creating custom dt.img ---"
	#./utilities/dtbtool -o $BUILTDIR/dt.img -s 2048 -p ./scripts/dtc/dtc ./arch/arm64/boot/dts/
	./tools/dtbtool -o $BUILTDIR/dt.img -s 2048 -p ./scripts/dtc/dtc ./arch/arm64/boot/dts/
	else
	echo "Device Tree STUCK in BUILD!"
	fi;

	echo ""
	echo "================================="
	echo "END   : FUNC_BUILD_DTIMAGE"
	echo "================================="
	echo ""
}

FUNC_BUILD_RAMDISK()
{
	echo ""
        echo "=============================================="
        echo "START : FUNC_BUILD_RAMDISK"
        echo "=============================================="
        echo ""
	echo "Packing ramdisk..."
	echo " "
	echo "Using compression: gzip"
	
# fix ramdisk permissions
cp ./utilities/ramdisk_fix_permissions.sh ./ramdisk/ramdisk_fix_permissions.sh
cd $RAMD
chmod 0777 ramdisk_fix_permissions.sh
./$RAMD/ramdisk_fix_permissions.sh 2>/dev/null
rm -rf /$RAMD/ramdisk_fix_permissions.sh

# make ramdisk

cd $RDIR

./utilities/mkbootfs ./ramdisk | gzip > ./ramdisk.gz

mv -f ramdisk.gz /$BUILTDIR

	echo ""
	echo "================================="
	echo "END   : FUNC_BUILD_RAMDISK"
	echo "================================="
	echo ""
}

FUNC_BUILD_BOOTIMG()
{
	echo ""
        echo "=============================================="
        echo "START : FUNC_BUILD_BOOTIMG"
        echo "=============================================="
        echo ""
	echo "***** Make boot.img *****"

./utilities/mkbootimg --kernel $KERN --ramdisk $RAM --cmdline "$CMDL" --board $BRD --base $BASE --pagesize $PS --dt $DTIMG --kernel_offset $KOFF --ramdisk_offset $ROFF --tags_offset $TOFF --output $KERNOUT

	echo -n "SEANDROIDENFORCE" >> $KERNOUT

	tar cvf shedkerneo.b5.tar boot.img
	md5sum -t shedkerneo.b5.tar >> shedkerneo.b5.tar
	mv shedkerneo.b5.tar shedkerneo.b5.tar.md5
	mv -f boot.img out/
	mv -f shedkerneo.b5.tar.md5 out/

	echo ""
	echo "================================="
	echo "END   : FUNC_BUILD_BOOTIMG"
	echo "================================="
	echo ""
}

####################################### COMPILE IMAGES #######################################

	if [ -e ./build_shedkerneo.log ]; then
	rm -rf ./build_shedkerneo.log
	fi;

(
    START_TIME=`date +%s`

# check if ccache installed, if not install
	echo ""
	if [ ! -e /usr/bin/ccache ]; then
	echo "You must install 'ccache' to continue.";
	sudo apt-get install -y ccache &&echo 'export PATH="/usr/lib/ccache:$PATH"' | tee -a ~/.bashrc &&source ~/.bashrc && echo $PATH
	else
	echo "'ccache' installed.";
	fi
# clear ccache
	echo ""
	read -p "Clear ccache but keeping the config file, 5sec timeout (y/n)? > " cca
	if [ "$cca" = "y" ]; then
	ccache -C
	fi;
	echo ""
	read -p "Do you want to use a stock (s) or custom generated (c) dt.img? (s/c) > " dt
# MAIN FUNCTION
	echo ""
	echo "Clear Folder"
	make clean
	make mrproper
	make distclean
	echo ""

	if [ -e $BUILTDIR/Image ]; then
	rm -f $BUILTDIR/Image
	fi;
	if [ -e $BUILTDIR/dt.img ]; then
	rm -f $BUILTDIR/dt.img
	fi;
	if [ -e $BUILTDIR/ramdisk.gz ]; then
	rm -f $BUILTDIR/ramdisk.gz
	fi;

export ARCH=$ARCH
export SUBARCH=$SUBARCH
export CROSS_COMPILE=$CROSS_COMPILE
export USE_CCACHE=1
export NUMBEROFCPUS=`grep 'processor' /proc/cpuinfo | wc -l`;

	if [ "$dt" = "c" -o "$dt" = "C" ]; then
	cp ./tools/MakefileDTS ./arch/arm64/boot/dts/Makefile
	rm -rf arch/arm64/boot/dts/exynos7580-universal7580_q.dtb
	rm -rf arch/arm64/boot/dts/exynos7580-universal7580_rev01.dtb
	else
	cp ./utilities/MakefileDTS ./arch/arm64/boot/dts/Makefile
	fi
	FUNC_BUILD_KERNEL
	if [ "$dt" = "c" -o "$dt" = "C" ]; then
	FUNC_BUILD_DTIMAGE
	fi
	if [ "$dt" = "s" -o "$dt" = "S" ]; then
	cp utilities/dt.img out/dt.img
	fi
	FUNC_BUILD_RAMDISK
	FUNC_BUILD_BOOTIMG

    END_TIME=`date +%s`

ELAPSED_TIME=$((END_TIME-START_TIME))

    echo "Total compile time is $ELAPSED_TIME seconds"

# Calculate size for all images and display on terminal output
du -k "$BUILTDIR/dt.img" | cut -f1 >sizDT
sizDT=$(head -n 1 sizDT)
du -k "$BUILTDIR/ramdisk.gz" | cut -f1 >sizRM
sizRM=$(head -n 1 sizRM)
du -k "$BUILTDIR/Image" | cut -f1 >sizKN
sizKN=$(head -n 1 sizKN)
du -k "$BUILTDIR/boot.img" | cut -f1 >sizBT
sizBT=$(head -n 1 sizBT)
echo "Kernel is $sizKN Kb"
echo "Ramdisk is $sizRM Kb"
echo "DT is $sizDT Kb"
echo "Total Boot file is $sizBT Kb"
rm -rf sizDT
rm -rf sizRM
rm -rf sizKN
rm -rf sizBT
rm -rf out/Image
rm -rf out/dt.img
rm -rf out/ramdisk.gz
rm -rf arch/arm64/boot/Image.gz
rm -rf arch/arm64/boot/Image.gz-dtb
echo ""
echo "Check 'out' folder to get kernel img and tar file"
echo ""
) 2>&1	 | tee -a ./build_shedkerneo.log

