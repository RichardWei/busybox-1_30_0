#!/bin/sh
# make
# sudo add-apt-repository ppa:ubuntu-toolchain-r/test
# sudo apt update
# sudo apt install gcc-arm-linux-gnueabihf=7.5.0-2019.12-0ubuntu1~18.04
# lsb_release -a


export PATH=$PATH:/usr/local/arm/gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf/bin
export CROSS_COMPILE=arm-linux-gnueabihf-
export ARCH=arm
make  clean
make  distclean
# make  defconfig
echo "Try to overwrite config for imx6ull"
cp config.txt .config
make   -j8

rootfs_path="/home/wei/linux/nfs/rootfs_dev"
# make install CONFIG_PREFIX=/home/wei/linux/nfs/rootfs_dev
make install CONFIG_PREFIX="${rootfs_path}"
echo "install path ${rootfs_path}"

if [ ! -d "${rootfs_path}/lib" ]; then
    mkdir -p "${rootfs_path}/lib"
fi
echo "copy arm gcc libc/lib to rootfs"
arm_gcc_lib=/usr/local/arm/gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf/arm-linux-gnueabihf
cp ${arm_gcc_lib}/libc/lib/*so* ${arm_gcc_lib}/libc/lib/*.a ${rootfs_path}/lib/ -d

echo "rm ld-linux-armhf.so.3 in rootfs"
rm ${rootfs_path}/lib/ld-linux-armhf.so.3
echo "cp new ld-linux-armhf.so.3"
cp ${arm_gcc_lib}/libc/lib/ld-linux-armhf.so.3 ${rootfs_path}/lib/
echo "cp ${arm_gcc_lib}/lib file"
cp ${arm_gcc_lib}/lib/*so* ${arm_gcc_lib}/lib/*.a ${rootfs_path}/lib/ -d


echo "cp lib to usr/lib"
if [ ! -d "${rootfs_path}/usr/lib" ]; then
    mkdir -p "${rootfs_path}/usr/lib"
fi

cp ${arm_gcc_lib}/libc/usr/lib/*so* ${arm_gcc_lib}/libc/usr/lib/*.a ${rootfs_path}/usr/lib/ -d

du ${rootfs_path}/lib ${rootfs_path}/usr/lib/ -sh
echo "creat dev,proc,mnt,sys,tmp,root"

if [ ! -d "${rootfs_path}/dev" ]; then
    mkdir -p "${rootfs_path}/dev"
fi

if [ ! -d "${rootfs_path}/proc" ]; then
    mkdir -p "${rootfs_path}/proc"
fi

if [ ! -d "${rootfs_path}/mnt" ]; then
    mkdir -p "${rootfs_path}/mnt"
fi

if [ ! -d "${rootfs_path}/sys" ]; then
    mkdir -p "${rootfs_path}/sys"
fi

if [ ! -d "${rootfs_path}/tmp" ]; then
    mkdir -p "${rootfs_path}/tmp"
fi

if [ ! -d "${rootfs_path}/root" ]; then
    mkdir -p "${rootfs_path}/root"
fi


if [ ! -d "${rootfs_path}/etc/init.d" ]; then
    mkdir -p "${rootfs_path}/etc/init.d"
fi


if [ -f "${rootfs_path}/etc/init.d/rcS" ]; then
    rm "${rootfs_path}/etc/init.d/rcS"
fi

rcS_Path=${rootfs_path}/etc/init.d/rcS
echo "touch ${rcS_Path}"

touch ${rcS_Path}
echo '#!/bin/sh
PATH=/sbin:/bin:/usr/sbin:/usr/bin:$PATH
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/lib:/usr/lib
export PATH LD_LIBRARY_PATH
mount -a
mkdir /dev/pts
mount -t devpts devpts /dev/pts
# echo /sbin/mdev > /proc/sys/kernel/hotplug
test -f /proc/sys/kernel/hotplug && echo /sbin/mdev > /proc/sys/kernel/hotplug
mdev -s' > ${rcS_Path}

chmod 777 ${rcS_Path}


fstab_Path=${rootfs_path}/etc/fstab
echo "touch ${fstab_Path}"

touch ${fstab_Path}
echo '#!/bin/sh
#<file system> <mount point> <type> <options> <dump> <pass>
proc /proc proc defaults 0 0
tmpfs /tmp tmpfs defaults 0 0
sysfs /sys sysfs defaults 0 0' > ${fstab_Path}


inittab_Path=${rootfs_path}/etc/inittab
echo "touch ${inittab_Path}"

touch ${inittab_Path}
echo '#etc/inittab
::sysinit:/etc/init.d/rcS
console::askfirst:-/bin/sh
::restart:/sbin/init
::ctrlaltdel:/sbin/reboot
::shutdown:/bin/umount -a -r
::shutdown:/sbin/swapoff -a' > ${inittab_Path}

echo "finsh in ${rootfs_path}"


