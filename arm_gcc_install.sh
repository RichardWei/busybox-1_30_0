#!/bin/sh
# syspath="arm"
# syspathfile="profile"

syspath="/usr/local/arm"
syspathfile="/etc/profile"

filename="gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf"
sudo rm -rf ${syspath}

sudo mkdir ${syspath}

sudo cp ${filename}.tar ${syspath} -f

# sudo mkdir -p ${syspath}/${filename}

sudo tar -xvf ${filename}.tar -C ${syspath}

# export PATH=$PATH:/usr/local/arm/gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf/bin
# echo 'export PATH=$PATH:/usr/local/arm/gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf/bin' >> ${syspathfile}
export PATH=$PATH:${syspath}/${filename}/bin
# source /etc/profile

arm-linux-gnueabihf-gcc -v
