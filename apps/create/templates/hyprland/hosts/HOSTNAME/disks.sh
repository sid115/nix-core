#!/usr/bin/env bash

SSD='/dev/disk/by-id/ata-MTFDDAK512TBN-1AR1ZABHA_UFZMT01J1AGPW4' # FIXME: Replace with your actual disk
MNT='/mnt'
SWAP_GB=32 # FIXME: Set swap size in GB > 0

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

swapoff --all
udevadm settle

wait_for_device $SSD

echo "Wiping filesystem on $SSD..."
wipefs -a $SSD

echo "Clearing partition table on $SSD..."
sgdisk --zap-all $SSD

echo "Partitioning $SSD..."
sgdisk -n1:1M:+1G         -t1:EF00 -c1:BOOT $SSD
sgdisk -n2:0:+"$SWAP_GB"G -t2:8200 -c2:SWAP $SSD
sgdisk -n3:0:0            -t3:8304 -c3:ROOT $SSD
partprobe -s $SSD
udevadm settle

wait_for_device ${SSD}-part1
wait_for_device ${SSD}-part2
wait_for_device ${SSD}-part3

echo "Formatting partitions..."
mkfs.vfat -F 32 -n BOOT "${SSD}-part1"
mkswap -L SWAP "${SSD}-part2"
mkfs.ext4 -L ROOT "${SSD}-part3"

echo "Mounting partitions..."
mount -o X-mount.mkdir "${SSD}-part3" "$MNT"
mkdir -p "$MNT/boot"
mount -t vfat -o fmask=0077,dmask=0077,iocharset=iso8859-1 "${SSD}-part1" "$MNT/boot"

echo "Enabling swap..."
swapon "${SSD}-part2"

echo "Partitioning and setup complete:"
lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT,LABEL
