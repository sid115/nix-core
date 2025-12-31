#!/usr/bin/env bash

SSD='/dev/sda'
MNT='/mnt'
SWAP_GB=4

# Helper function to wait for devices
wait_for_device() {
  local device=$1
  echo "Waiting for device: $device ..."
  while [[ ! -e $device ]]; do
    sleep 1
  done
  echo "Device $device is ready."
}

# Function to install a package if it's not already installed
install_if_missing() {
  local cmd="$1"
  local package="$2"
  if ! command -v "$cmd" &> /dev/null; then
    echo "$cmd not found, installing $package..."
    nix-env -iA "nixos.$package"
  fi
}

install_if_missing "sgdisk" "gptfdisk"
install_if_missing "partprobe" "parted"

wait_for_device $SSD

echo "Wiping filesystem on $SSD..."
wipefs -a $SSD

echo "Clearing partition table on $SSD..."
sgdisk --zap-all $SSD

echo "Partitioning $SSD..."
parted -s "$SSD" \
  mklabel gpt \
  mkpart ESP fat32 1MiB 513MiB \
  set 1 esp on \
  mkpart primary linux-swap 513MiB "$((513 + SWAP_GB*1024))"MiB \
  mkpart primary ext4 "$((513 + SWAP_GB*1024))"MiB 100%
partprobe -s $SSD
udevadm settle

wait_for_device ${SSD}-part1
wait_for_device ${SSD}-part2
wait_for_device ${SSD}-part3

echo "Formatting partitions..."
mkfs.vfat -n BOOT "${SSD}1"
mkswap -L SWAP "${SSD}2"
mkfs.ext4 -L ROOT "${SSD}3"

echo "Mounting partitions..."
mount "${SSD}3" "$MNT"
mkdir -p "$MNT/boot"
mount "${SSD}1" "$MNT/boot"

echo "Enabling swap..."
swapon "${SSD}2"

echo "Partitioning and setup complete:"
lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT,LABEL
