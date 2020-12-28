#!/bin/sh
set -euxo pipefail
reset
QEMU_SHARE=$(echo /opt/homebrew/Cellar/qemu/*/share/qemu/)
BOOTVARS="debian.bootvars"
DISK0="debian-disk0.qcow2"
CDROM="debian-bullseye-DI-alpha3-arm64-netinst.iso"
if [ ! -e "${BOOTVARS}" ]; then
    echo copying boot variables flash
    cp "${QEMU_SHARE}"/edk2-arm-vars.fd "${BOOTVARS}"
fi
if [ ! -e "${DISK0}" ]; then
    echo creating disk image "${DISK0}"
    qemu-img create -f qcow2 "${DISK0}" 10G
fi
if [ ! -e installed ]; then
    if [ ! -e "$CDROM" ]; then
        echo downloading installer CD image
        curl -OL "https://cdimage.debian.org/cdimage/bullseye_di_alpha3/arm64/iso-cd/${CDROM}"
    fi
    CDARGS="-drive file="${CDROM}",if=none,id=drive-scsi1,media=cdrom -device scsi-cd,bus=scsihw0.0,channel=0,scsi-id=1,lun=0,drive=drive-scsi1,id=scsi1"
else
    CDARGS=""
fi

ulimit -c 0  # disable coredumps
qemu-system-aarch64 \
    -M virt,gic-version=3,highmem=off,iommu=smmuv3,accel=hvf \
    -device pci-bridge,id=pci.0,chassis_nr=2 \
    -device virtio-scsi-pci,bus=pci.0,addr=0x5,id=scsihw0 \
    -drive file="${QEMU_SHARE}"/edk2-aarch64-code.fd,if=pflash,format=raw \
    -drive file="${BOOTVARS}",if=pflash,format=raw \
    -drive file="${DISK0}",if=none,id=drive-scsi0,format=qcow2 \
    -device scsi-hd,bus=scsihw0.0,channel=0,scsi-id=0,lun=0,drive=drive-scsi0,id=scsi0 \
    $CDARGS \
    -device qemu-xhci -device usb-kbd -device usb-tablet \
    -device virtio-gpu-pci \
    -display cocoa \
    -m 4096 \
    -cpu cortex-a72 \
    -smp 2 \
    -serial mon:stdio \
    -d guest_errors,cpu_reset
