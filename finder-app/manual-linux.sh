#!/bin/bash
# Script outline to install and build kernel.
# Author: Siddhant Jajoo.

set -e
set -u

OUTDIR=/tmp/aeld
KERNEL_REPO=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
KERNEL_VERSION=v5.1.10
BUSYBOX_VERSION=1_33_1
FINDER_APP_DIR=$(realpath $(dirname $0))
ARCH=arm64
CROSS_COMPILE=aarch64-none-linux-gnu-

if [ $# -lt 1 ]
then
	echo "Using default directory ${OUTDIR} for output"
else
	OUTDIR=$1
	echo "Using passed directory ${OUTDIR} for output"
fi

mkdir -p ${OUTDIR}

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/linux-stable" ]; then
    #Clone only if the repository does not exist.
	echo "CLONING GIT LINUX STABLE VERSION ${KERNEL_VERSION} IN ${OUTDIR}"
	git clone ${KERNEL_REPO} --depth 1 --single-branch --branch ${KERNEL_VERSION}
fi
if [ ! -e ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ]; then
    cd linux-stable
    echo "Checking out version ${KERNEL_VERSION}"
    git checkout ${KERNEL_VERSION}

    sudo apt-get update
    sudo apt-get install -y --no-install-recommends bc u-boot-tools kmod cpio flex bison libssl-dev psmisc
    sudo apt-get install -y qemu-system-arm

    # Step 1: Clean the Build (see: Building the Linux Kernel video @ 6:47)
    echo "Step 1: Clean the Build"
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} mrproper

    # Step 2: Create Config (see: Building the Linux Kernel video @ 7:10)
    echo "Step 2: Create Config"
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} defconfig

    # Step 3: Build vmlinux (see: Building the Linux Kernel video @ 7:28)
    echo "Step 3: Build vmlinux"
    make -j4 ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} all

    # Step 4: Build devicetree (see: Building the Linux Kernel video @ 7:53)
    echo "Step 4: Build devicetree"
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} dtbs

fi

echo "Adding the Image in outdir"
cp ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ${OUTDIR}

echo "Creating the staging directory for the root filesystem"
cd "$OUTDIR"
if [ -d "${OUTDIR}/rootfs" ]
then
	echo "Deleting rootfs directory at ${OUTDIR}/rootfs and starting over"
    sudo rm  -rf ${OUTDIR}/rootfs
fi

# Create necessary base directories (see: Linux Root Filesystems video @ 6:49)
echo "Create necessary base directories"
mkdir -p rootfs/bin rootfs/dev rootfs/etc rootfs/lib rootfs/lib64 rootfs/proc rootfs/sys rootfs/sbin rootfs/tmp rootfs/usr rootfs/var rootfs/home
mkdir -p rootfs/usr/bin rootfs/usr/lib rootfs/usr/sbin 
mkdir -p rootfs/var/log
mkdir -p rootfs/home/conf

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/busybox" ]
then
git clone git://busybox.net/busybox.git
    cd busybox
    git checkout ${BUSYBOX_VERSION}
    # Configure busybox (see: Linux Root Filesystems video @ 8:47)
    echo "Configure busybox"
    make distclean
    make defconfig

else
    cd busybox
fi

# Make and install busybox (see: Linux Root Filesystems video @ 8:47)
echo "Make and install busybox"
make -j4 ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}
make CONFIG_PREFIX="${OUTDIR}/rootfs" ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} install

echo "Library dependencies"
cd ${OUTDIR}/rootfs
${CROSS_COMPILE}readelf -a bin/busybox | grep "program interpreter"
${CROSS_COMPILE}readelf -a bin/busybox | grep "Shared library"

# Add library dependencies to rootfs (see: Linux Root Filesystems video @ 9:21)
echo "Add library dependencies to rootfs"
SYSROOT=$(${CROSS_COMPILE}gcc -print-sysroot)
cp ${SYSROOT}/lib/ld-linux-aarch64.so.1 lib/
cp ${SYSROOT}/lib64/libm.so.6 lib64/
cp ${SYSROOT}/lib64/libresolv.so.2 lib64/
cp ${SYSROOT}/lib64/libc.so.6 lib64/

# Make device nodes (see: Linux Root Filesystems video @ 11:32)
echo "Make device nodes"
sudo mknod -m 666 dev/null c 1 3
sudo mknod -m 666 dev/console c 5 1

# Clean and build the writer utility from the previous assignments
echo "Clean and build the writer utility from the previous assignments"
cd ${FINDER_APP_DIR}
make clean
make CROSS_COMPILE=${CROSS_COMPILE}

# Copy the finder related scripts and executables to the /home director on the target rootfs
echo "Copy the finder related scripts and executables to the /home director on the target rootfs"
cp ${FINDER_APP_DIR}/finder.sh ${OUTDIR}/rootfs/home
cp ${FINDER_APP_DIR}/finder-test.sh ${OUTDIR}/rootfs/home
cp ${FINDER_APP_DIR}/writer ${OUTDIR}/rootfs/home
cp ${FINDER_APP_DIR}/autorun-qemu.sh ${OUTDIR}/rootfs/home
cp ${FINDER_APP_DIR}/conf/assignment.txt ${OUTDIR}/rootfs/home/conf
cp ${FINDER_APP_DIR}/conf/username.txt ${OUTDIR}/rootfs/home/conf


# Chown the root directory (see: Linux Root Filesystems video @ 13:25)
echo "Chown the root directory"
cd ${OUTDIR}/rootfs
sudo chown -R root:root *

# Create initramfs.cpio.gz (see: Linux Root Filesystems video @ 13:25)
echo "Create initramfs.cpio.gz"
cd ${OUTDIR}/rootfs
find . | cpio -H newc -ov --owner root:root > ${OUTDIR}/initramfs.cpio
cd ${OUTDIR}
gzip -f initramfs.cpio
