#
# Copyright (C) 2023 xiaoleGun <1592501605@qq.com>
#

# Architecture(e.g. $ARCH or arm)
# 芯片架构(例如: $ARCH或arm)
ARCH=arm64

# Build extra command
# 额外构建命令
EXTRA_COMMAND="LD=ld.lld"

# Clang version(e.g. r416183b)
# Clang版本(例如: r416183b)
CLANGVERSION=

# Kernel defconfig(e.g. vendor/wayne_defconfig)
# 内核配置文件(例如: vendor/wayne_defconfig)
DEFCONFIG=

# Device codename(e.g. wayne)
# 设备代号(例如: wayne)
DEVICE=

# Files(e.g. Image, Image.gz, Image.gz-dtb)
# 内核文件(例如 Image, Image.gz, Image.gz-dtb)
FILES=

# Use KernelSU(true is use)
USEKSU=

# Clean source prior building(true is YES)
# 净编译(设true为净编译)
INSTALLCLEAN=

# DO NOT CHANGE #
# 不需要更改 #
DATE=$(TZ=Asia/Shanghai date +"%Y%m%d-%H%M%S")
LOCAL_PATH=$(pwd)
KBUILD_BUILD_USER=$(echo $USER)
if [ ! -d "build_out" ]; than
    mkdir build_out
fi

setClangAndGcc() {	
    if [ ! -d "clang-aosp" ] && [ ! -f clang-aosp/AndroidVersion.txt ]; then
        echo "--> Cloning Clang"
        rm -rf clang-aosp 
		mkdir clang-aosp
		wget https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/master-kernel-build-2022/clang-$CLANGVERSION.tar.gz
		tar -C clang-aosp/ -zxvf clang-$CLANGVERSION.tar.gz
	fi

	if [ ! -d "gcc-aosp" ] && [ ! -f gcc-aosp/repo.prop ]; then
        echo "--> Cloning Gcc"
        rm -rf gcc-aosp 
		mkdir gcc-aosp
		wget https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/+archive/refs/tags/android-11.0.0_r35.tar.gz
		tar -C gcc-aosp/ -zxvf android-11.0.0_r35.tar.gz
	fi
    export PATH=$LOCAL_PATH/clang-aosp/bin:$PATH
	export GCC_PATH=$LOCAL_PATH/gcc-aosp
}

installClean() {
    if [ $INSTALLCLEAN = true  ]; than
        make clean && make mrproper && rm -rf out
    fi
}

setupAnyKernel3() {
    if [ -d AnyKernel3 ] && [ ! -f AnyKernel3/anykernel.sh ]; then
        echo "--> Setup AnyKernel3"
        rm -rf AnyKernel3
		git clone https://github.com/osm0sis/AnyKernel3
        sed -i 's/do.devicecheck=1/do.devicecheck=0/g' AnyKernel3/anykernel.sh
        sed -i 's!block=/dev/block/platform/omap/omap_hsmmc.0/by-name/boot;!block=auto;!g' AnyKernel3/anykernel.sh
        sed -i 's/is_slot_device=0;/is_slot_device=auto;/g' AnyKernel3/anykernel.sh
        rm -rf AnyKernel3/.git* AnyKernel3/README.md
	fi
}

setupKernelSU() {
    echo "--> Setup KernelSU"
    curl -LSs "https://raw.githubusercontent.com/tiann/KernelSU/main/kernel/setup.sh" | bash -
    echo "CONFIG_MODULES=y" >> arch/$ARCH/configs/$DEFCONFIG
    echo "CONFIG_KPROBES=y" >> arch/$ARCH/configs/$DEFCONFIG
    echo "CONFIG_HAVE_KPROBES=y" >> arch/$ARCH/configs/$DEFCONFIG
    echo "CONFIG_KPROBE_EVENTS=y" >> arch/$ARCH/configs/$DEFCONFIG
    export USEKSU=KernelSU
}

buildKernel() {
    echo "--> Building Kernel"
    make O=out CROSS_COMPILE=$GCC_PATH/bin/aarch64-linux-android- CLANG_TRIPLE=aarch64-linux-gnu- CC=clang $EXTRA_COMMAND $DEFCONFIG
    make O=out CROSS_COMPILE=$GCC_PATH/bin/aarch64-linux-android- CLANG_TRIPLE=aarch64-linux-gnu- CC=clang $EXTRA_COMMAND
}

makeAnyKernel3() {
    echo "--> Making AnyKernel3"
    cp out/arch/$ARCH/boot/$FILE AnyKernel3/
    zip -r build_out/$DEVICE-$USEKSU-$DATE AnyKernel3/*
}

START=`date +%s`
setClangAndGcc
installClean
setupAnyKernel3
if [ $USEKSU = true ]; than
setupKernelSU
fi
buildKernel
makeAnyKernel3

END=`date +%s`
ELAPSEDM=$(($(($END-$START))/60))
ELAPSEDS=$(($(($END-$START))-$ELAPSEDM*60))

echo ""
echo "--> Buildbot completed in $ELAPSEDM minutes and $ELAPSEDS seconds"
echo ""