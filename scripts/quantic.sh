#!/bin/bash

workdir="/home/segfault/kernel/quantic"

# Telegram Stuff

priv_to_me="/home/dump/configs/priv.conf"
newpeeps="/home/dump/configs/segfault.conf"

cd /home/segfault/kernel/quantic
build_kernel() {
rm -rf out
mkdir out
wait
echo -e ${cya}"cleaned out directory"${txtrst};

export KBUILD_BUILD_USER="by-ayrton990"
export KBUILD_BUILD_HOST="built_by_segfault"

echo -e "\rBuild starting thank you for waiting"
BLINK="https://ci.goindi.org/job/$JOB_NAME/$BUILD_ID/console"

# Send message to TG

read -r -d '' msg <<EOT
<b>Kernel Build Started</b>
Quantic for apollo/apollon 
<b>Console log:-</b> <a href="${BLINK}">here</a>
EOT

sudo telegram-send --format html "${msg}" --config ${priv_to_me} --disable-web-page-preview
sudo telegram-send --format html "${msg}" --config ${newpeeps} --disable-web-page-preview

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
echo -e ${cya}"cleaned dtbo.img directory from anykernel"${txtrst};

# Packing time
cp -ar out/arch/arm64/boot/Image AnyKernel3/
echo -e ${cya}"Kernel binary installed"${txtrst};
cp -ar out/arch/arm64/boot/dtbo.img AnyKernel3/
echo -e ${cya}"dtbo.img installed"${txtrst};

#Ziping time
cd AnyKernel3/
zip -r ../zip/Quantic_SM8250-OSS-apollo-upstream-$(date +"%d%m%Y-%H%M").zip *
}

build_kernel
packaging

#Pushing Kernel to GoIndi
KERNEL=Quantic_SM8250-OSS-apollo-upstream-$(date +"%d%m%Y-%H%M").zip
sudo mkdir -p /home/dump/sites/goindi/downloads/segfault/apollo/kernel
cd ../zip/
sudo cp $KERNEL /home/dump/sites/goindi/downloads/segfault/apollo/kernel

#Telegram Successful 
filename="$(basename $KERNEL)"
LINK="https://download.goindi.org/segfault/apollo/kernel/$filename"
size="$(du -h ${KERNEL}|awk '{print $1}')"
mdsum="$(md5sum ${KERNEL}|awk '{print $1}')"
read -r -d '' priv <<EOT
Yay it's finished !
Quantic Kernel for apollo/apollon 
<b>Download:-</b> <a href="${LINK}">here</a>
<b>Size:-</b> <pre> ${size}</pre>
<b>Md5:-</b> <pre> ${mdsum}</pre>  
EOT

sudo telegram-send --format html "$priv" --config ${priv_to_me} --disable-web-page-preview
sudo telegram-send --format html "$priv" --config ${newpeeps} --disable-web-page-preview