#!/usr/bin/env bash
declare -a SSDs=(
  # '/dev/disk/by-id/abc123'
)

declare -a HDDs=(
  # '/dev/disk/by-id/def456'
)

declare -a DATA_DATASETS=(
  # 'dataset'
)

MNT='/mnt'
SWAP_GB=32

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

# Ensure swap parts are off
swapoff --all
udevadm settle

### SSDs ###
echo "Setting up SSDs..."

# Wait for SSD devices to be ready
for ssd in "${SSDs[@]}"; do
  wait_for_device "$ssd"
done

# Wipe and partition SSDs
for i in "${!SSDs[@]}"; do
  ssd="${SSDs[$i]}"
  ssd_num=$((i + 1))
  
  echo "Processing SSD $ssd_num: $ssd"
  
  # Wipe filesystems
  wipefs -a "$ssd"
  
  # Clear part tables
  sgdisk --zap-all "$ssd"
  
  # Partition disk
  sgdisk -n1:1M:+1G         -t1:EF00 -c1:BOOT$ssd_num "$ssd"
  sgdisk -n2:0:+"$SWAP_GB"G -t2:8200 -c2:SWAP$ssd_num "$ssd"
  sgdisk -n3:0:0            -t3:BF00 -c3:ROOT$ssd_num "$ssd"
  
  partprobe -s "$ssd"
  udevadm settle
  wait_for_device "${ssd}-part3"
done

# Create root pool
echo "Creating root pool..."
zpool create -f -o ashift=12 -o autotrim=on -R "$MNT" -O acltype=posixacl -O canmount=off -O dnodesize=auto -O normalization=formD -O relatime=on -O xattr=sa -O mountpoint=none rpool mirror "${SSDs[0]}"-part3 "${SSDs[1]}"-part3

# Create and mount root system container
zfs create -o canmount=noauto -o mountpoint=legacy rpool/root
mount -o X-mount.mkdir -t zfs rpool/root "$MNT"

# Create root datasets
declare -a ROOT_DATASETS=('home' 'nix' 'tmp' 'var')
for dataset in "${ROOT_DATASETS[@]}"; do
  zfs create -o mountpoint=legacy "rpool/$dataset"
  mount -o X-mount.mkdir -t zfs "rpool/$dataset" "$MNT/$dataset"
done

# Format boot and swap partitions
for i in "${!SSDs[@]}"; do
  ssd="${SSDs[$i]}"
  ssd_num=$((i + 1))
  
  mkfs.vfat -F 32 -n BOOT$ssd_num "${ssd}"-part1
  mkswap -L SWAP$ssd_num "${ssd}"-part2
  swapon -L SWAP$ssd_num
done

# Mount first boot partition
mount -t vfat -o fmask=0077,dmask=0077,iocharset=iso8859-1,X-mount.mkdir -L BOOT1 "$MNT"/boot

### HDDs ###
echo "Setting up HDDs..."

# Wait for HDD devices to be ready
for hdd in "${HDDs[@]}"; do
  wait_for_device "$hdd"
done

# Wipe and partition HDDs
for i in "${!HDDs[@]}"; do
  hdd="${HDDs[$i]}"
  hdd_num=$((i + 1))
  
  echo "Processing HDD $hdd_num: $hdd"
  
  wipefs -a "$hdd"
  sgdisk --zap-all "$hdd"
  sgdisk -n1:0:0 -t1:BF00 -c1:DATA$hdd_num "$hdd"
done

udevadm settle

# Wait for all HDD partitions to appear
for hdd in "${HDDs[@]}"; do
  wait_for_device "${hdd}-part1"
done

# Create data pool
echo "Creating data pool..."
mkdir -p "$MNT"/data

hdd_partitions=()
for hdd in "${HDDs[@]}"; do
  hdd_partitions+=("${hdd}-part1")
done

zpool create -f -o ashift=12 -o autotrim=on -R "$MNT" -O acltype=posixacl -O xattr=sa -O dnodesize=auto -O compression=lz4 -O normalization=formD -O relatime=on -O mountpoint=none dpool raidz "${hdd_partitions[@]}"

# Create and mount data root container
zfs create -o canmount=noauto -o mountpoint=legacy dpool/data
mount -o X-mount.mkdir -t zfs dpool/data "$MNT"/data

# Create and mount data datasets
for dataset in "${DATA_DATASETS[@]}"; do
  zfs create -o mountpoint=legacy "dpool/data/$dataset"
  mount -o X-mount.mkdir -t zfs "dpool/data/$dataset" "$MNT/data/$dataset"
done

echo "Setup complete."
