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

swapoff --all
udevadm settle
wait_for_device $SSD

echo "Wiping filesystem on $SSD..."
wipefs -a $SSD

echo "Creating new MBR partition table on $SSD..."
fdisk $SSD << EOF
o
w
EOF

echo "Partitioning $SSD..."
fdisk $SSD << EOF
n
p
1

+512M
a
n
p
2

+${SWAP_GB}G
t
2
82
n
p
3


w
EOF

partprobe -s $SSD
udevadm settle
wait_for_device "${SSD}1"
wait_for_device "${SSD}2"
wait_for_device "${SSD}3"

echo "Formatting partitions..."
mkfs.ext4 -L BOOT "${SSD}1"
mkswap -L SWAP "${SSD}2"
mkfs.ext4 -L ROOT "${SSD}3"

echo "Mounting partitions..."
mount -o X-mount.mkdir "${SSD}3" "$MNT"
mkdir -p "$MNT/boot"
mount "${SSD}1" "$MNT/boot"

echo "Enabling swap..."
swapon "${SSD}2"

echo "Partitioning and setup complete:"
lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT,LABEL
