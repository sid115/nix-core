# Password Manager

This module will automatically install [`pass`](https://www.passwordstore.org/) as your password manager. It also provides a custom version of [`passmenu`](https://git.zx2c4.com/password-store/tree/contrib/dmenu/passmenu) using `bemenu` for Wayland sessions called `passmenu-bemenu` and configures [passff](https://codeberg.org/PassFF/passff) for your web browser.

View the [*nix-core* Home Manager module on GitHub](https://github.com/sid115/nix-core/tree/master/modules/home/password-manager).

## Setup

It is assumed that you have a GPG key.

### HM config

```nix
imports = [
  inputs.core.homeModules.passwordManager
];

programs.passwordManager = {
  enable = true;
  key = "YOUR_GPG_KEYGRIP";
  wayland = true; # if you are using Wayland
};
```

> Get your keygrip with `gpg -K --with-keygrip`

### Password Store

`pass` uses a Password Store to manage your password files. If this is your first time using `pass`, follow option _a)_. If you already have a remote git repository to store your password-store, follow option _b)_.

#### a) Initialize a new Password Store

Read the introduction and setup guide on the [pass home page](https://passwordstore.org).

#### b) Cloning your remote password-store repository

The following guide assumes that you have your private GPG key on a luks encrypted USB partition which is needed to access your remote repo through ssh.

1. **Identify the USB device**:
   Identify the device name for your USB drive using the `lsblk` or `fdisk -l` command.

   ```bash
   lsblk
   ```

   Look for the device corresponding to your USB drive (e.g., `/dev/sdb1`).

2. **Unlock the LUKS partition**:
   Unlock the LUKS partition with the `cryptsetup luksOpen` command. Replace `/dev/sdX1` with the actual device name of your USB partition.

   ```bash
   sudo cryptsetup luksOpen /dev/sdX1 crypt
   ```

   You will be prompted to enter the passphrase for the LUKS partition.

3. **Mount the unlocked partition**:
   Mount the unlocked LUKS partition to access the files.

   ```bash
   sudo mount /dev/mapper/crypt /mnt
   ```

4. **Import the GPG key**:
   Use the `gpg --import` command to import the GPG key from the mounted USB partition.

   ```bash
   gpg --import /mnt/path/to/privatekey.gpg
   ```

5. **Unmount and close the LUKS partition**:
   After importing the key, unmount the partition and close the LUKS mapping.

   ```bash
   sudo umount /mnt
   sudo cryptsetup luksClose crypt
   ```

6. **Clone your password store repository**:
   Clone your password store repository using the `git clone` command, for example:

   ```bash
   git clone ssh://example.tld:/home/you/git/password-store.git ~/.local/share/password-store
   ```
