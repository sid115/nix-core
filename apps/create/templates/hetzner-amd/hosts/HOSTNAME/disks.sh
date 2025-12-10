#!/usr/bin/env bash
set -e
SSD='/dev/sda'
MNT='/mnt'
SWAP_GB=4

wait_for_device() {
  while [[ ! -e $1 ]]; do sleep 0.1; done
}

swapoff --all || true
udevadm settle
wait_for_device "$SSD"

wipefs -a "$SSD"

parted -s "$SSD" \
  mklabel gpt \
  mkpart ESP fat32 1MiB 513MiB \
  set 1 esp on \
  mkpart primary linux-swap 513MiB "$((513 + SWAP_GB*1024))"MiB \
  mkpart primary ext4 "$((513 + SWAP_GB*1024))"MiB 100%

partprobe -s "$SSD"
udevadm settle
wait_for_device "${SSD}1"
wait_for_device "${SSD}2"
wait_for_device "${SSD}3"

mkfs.vfat -n BOOT "${SSD}1"
mkswap -L SWAP "${SSD}2"
mkfs.ext4 -L ROOT "${SSD}3"

mount "${SSD}3" "$MNT"
mkdir -p "$MNT/boot"
mount "${SSD}1" "$MNT/boot"
swapon "${SSD}2"

lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT,LABEL

