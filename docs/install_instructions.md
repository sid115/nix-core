# Installation Guide

This guide will walk you through installing NixOS using the provided installation script [`install.sh`](../apps/install/install.sh).

## Prerequisites

1. **Bootable NixOS Installation Medium**: Make sure you have booted into NixOS live environment from the [Minimal ISO image](https://nixos.org/download/#nixos-iso). Read the [official NixOS installation guide](https://nixos.org/manual/nixos/unstable/#sec-obtaining) for more information on how to create a bootable NixOS USB drive.
1. **Network Connection**: Ensure the target machine is connected to the internet.
1. **Host configuration**: The target machine needs to have a working NixOS configuration inside your own flake. A hardware configuration is not required as it can be generated automatically during installation.
1. **Disks setup**: The target machine needs to have a working disk configuration or partitioning script inside `hosts/HOSTNAME`. Disko expects its configuration to be in `hosts/HOSTNAME/disks.nix`. Alternatively, a shell script can be provided at `hosts/HOSTNAME/disks.sh` that will format, partition, and mount disks.

> Using UEFI is recommended.

### Optional: Virt-Manager config for Wayland

If you want to install NixOS with Wayland support inside a VM using Virt-Manager, enable 3D acceleration by checking `Customize configuration before install`:

1. Go to `Display <VNC or Spice>` and select `Spice Server` under `Type`. Select `None` under `Listen type`. Check `OpenGL` and select a device that is *not* from Nvidia.
1. Go to `Video <some name>` and select `Virtio` under `Model`. Check `3D acceleration`.
1. Click `Begin installation` in the top left corner.

If you get the error:

```plaintext
Unable to complete install: 'unsupported configuration: domain configuration does not support video model 'virtio''
```

Install the package `qemu-full`:

```shell
sudo pacman -Syy qemu-full
```

> assuming you are on Arch Linux

Then, reboot.

## Steps

Boot into NixOS ISO image on your target machine.

### 0. SSH into the Target Machine
If you are using a remote machine, set a password for the user _nixos_ using `passwd`. Then, SSH into it using the following command:

```bash
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no nixos@<host-ip-address>
```

> Replace `<host-ip-address>` with the IP address of the target machine which can be found using `ip a`.

### 1. Become root
The default user `nixos` has sudo privileges. Become root to run the install script:

```bash
sudo -i
```

### 2. Run the Install Script
Download the install script to the target machine and run it:

```bash
nix --experimental-features "nix-command flakes" run github:sid115/nix-core#apps.x86_64-linux.install -- \
-n HOST \
-r REPOSITORY
```

> Replace `HOST` with the name of your target machine.   
> Replace `REPOSITORY` with your flake URL.   
> You can specify a branch with `-b BRANCH` (default: `master`)   
> Print the usage page with `-h`.   
> Change the architecture if needed.

### 3. Reboot your System
Once the installation completes, unmount the installation medium:

```bash
umount -Rl /mnt
```

> If you have your root file system on ZFS, export all pools: `zpool export -a`

Then, you can safely remove the installation medium and reboot your machine:

> If you generated a new hardware configuration, you should save it before rebooting:   
> `cat /tmp/nixos/hosts/HOSTNAME/hardware.nix`

```bash
reboot now
```

### 4. Login
Upon reboot, your system will boot into the newly installed NixOS. Login as a valid user defined in the configuration of the host (`hosts/HOSTNAME/default.nix`). The default initial password is `changeme`. Change your password with `passwd` after login.

### 5. Optional: Import age keys
If you use sops-nix with age in you Home Manager configuration, you need to import your age keys:

```bash
mkdir -p ~/.config/sops/age
cp /PATH/TO/YOUR/keys.txt ~/.config/sops/age/keys.txt
```

### 6. Clone your Repository
Git is installed on every system by default. Clone your flake repository to your home directory:

```bash
git clone YOUR_GIT_REPO_URL ~/.config/nixos
```

> The rebuild script expects your flake to be in `~/.config/nixos`

### 7. Apply your Home Manager Configuration
Home Manager is not installed by default. Enter the development shell to apply the configuration:

```bash
nix-shell ~/.config/nixos/shell.nix --run 'rebuild home'
```

### 8. Reboot your System
Once the home-manager configuration is applied, reboot your system:

```bash
sudo reboot now
```

You may now log in. Your system is now fully configured.

# Installing NixOS on Raspberry Pi 4 & 5

## Prerequisites

- **Raspberry Pi 4 or 5** (This guide has been specifically tested on the Pi 4!)
- **SD card** (minimum 8GB)
- **Internet connection**
- **Existing nix-core configuration**:  
  The [`boot.nix`](https://github.com/sid115/nix-core/blob/develop/templates/nix-config/pi/hosts/HOSTNAME/boot.nix) and [`hardware.nix`](https://github.com/sid115/nix-core/blob/develop/templates/nix-config/pi/hosts/HOSTNAME/hardware.nix) files must be set up as shown in the examples.  
  Alternatively, you can use the create script — just make sure to use the [pi template](https://github.com/sid115/nix-core/tree/develop/templates/nix-config/pi)!

---

## Setup

### 0. Flash the SD Card

Download the latest [nixos-am image](https://hydra.nixos.org/job/nixos/trunk-combined/nixos.sd_image.aarch64-linux) and flash it to your SD card.

```bash
# Install required tools
nix-shell -p wget zstd curl

# Get the latest image URL and download it
wget $IMAGE_URL

# Extract the image
unzstd -d nixos-sd-image-*-aarch64-linux.img.zst

# Flash the image to SD card (replace sdX with your device!)
sudo dd if=nixos-sd-image-*-aarch64-linux.img of=/dev/sdX bs=4096 conv=fsync status=progress
```

---

### 1. Update Firmware

Boot the Pi with the flashed SD card and update the firmware.

```bash
# Enter a nix-shell with EEPROM tools
nix-shell -p raspberrypi-eeprom

# Mount the firmware partition
sudo mount /dev/disk/by-label/FIRMWARE /mnt

# Update firmware
sudo BOOTFS=/mnt FIRMWARE_RELEASE_STATUS=stable rpi-eeprom-update -d -a

# Reboot to apply changes
reboot
```

> **Note:**  
> You may need to apply the firmware update a second time if the firmware is too outdated.

---

### 2. Clone Configuration

Manually clone your configuration repository.

```bash
# Install Git
nix-shell -p git

# Clone your repository
git clone YOURGITURL /etc/nixos
```

---

### 3. Build the System

Build and switch to your new configuration:

```bash
# Build and apply the configuration
sudo nixos-rebuild switch --flake /etc/nixos#HOSTNAME
```

Reboot your system and enjoy using **NixOS**!

---

> **Example:**  
> If you want an example configuration, check [this repository](https://github.com/stherm/nix-config/) for the host **PI4HM**.

