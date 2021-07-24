#!/bin/bash

workdir="/home/segfault/qk"
cd /home/segfault/qk
build_kernel() {
rm -rf out
mkdir out
wait
echo -e ${cya}"cleaned out directory"${txtrst};

export KBUILD_BUILD_USER="ayrton990-segfault"
export KBUILD_BUILD_HOST="Atomic_builder"

make O=out ARCH=arm64 vendor/apollo_defconfig

PATH="${PWD}/proton-clang/bin:${PATH}" \
make -j$(nproc --all) O=out \
                      ARCH=arm64 \
                      CC=clang \
                      NM=llvm-nm \
                      OBJCOPY=llvm-objcopy \
                      OBJDUMP=llvm-objdump \
                      STRIP=llvm-strip \
                      CROSS_COMPILE=aarch64-linux-gnu- | tee kernel.txt

}

packaging() {

# Clean-up time
rm -rf AnyKernel3/Image
echo -e ${cya}"wiped Image binary from anykernel"${txtrst};
rm -rf AnyKernel3/dtbo.img
echo -e ${cya}"clened dtbo.img directory from anykernel"${txtrst};

# Packing time
cp -ar out/arch/arm64/boot/Image AnyKernel3/
echo -e ${cya}"Kernel binary installed"${txtrst};
cp -ar out/arch/arm64/boot/dtbo.img AnyKernel3/
echo -e ${cya}"dtbo.img installed"${txtrst};

#Ziping time
cd AnyKernel3/
zip -r ../zip/Quantic_SM8250-OSS-apollo-r3.3.zip *
}

gdrive_push() {
cd ..
rclone copy --config="/home/segfault/.config/rclone/rclone.conf" Quantic_SM8250-OSS-apollo-r3.3.zip gdrive:android
echo -e ${cya}"Build pushed to drive"${txtrst};
}

build_kernel
packaging
#gdrive_push