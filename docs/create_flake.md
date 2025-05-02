# Create your own nix-config flake

You need to have the Nix package manager installed. If you have not done so already, follow the [official installation instructions](https://nixos.org/download/).

Run the [`create` script](../apps/create/create.sh) to initialize your desired [nix-config template](../templates/nix-config/):

```bash
nix --experimental-features "nix-command flakes" run github:sid115/nix-core#apps.x86_64-linux.create -- \
-t TEMPLATE \
-u USERNAME \
-H HOST \
--git-name GIT_NAME \
--git-email GIT_EMAIL \
-d ~/.config/nixos
```

> Change the architecture if needed. Supported architectures are listet under `supportedSystems` inside [`flake.nix`](../flake.nix).

See the script's help page for reference:

```
Usage: create -u|--user USERNAME -H|--host HOSTNAME -d|--directory PATH/TO/EMPTY/DIRECTORY -t|--template TEMPLATE [--git-name GIT_NAME] [--git-email GIT_EMAIL]

Options:
    -u, --user USERNAME        Specify the username (mandatory)
    -H, --host HOSTNAME        Specify the hostname (mandatory)
    -d, --directory DIRECTORY  Path to an empty directory (mandatory)
    -t, --template TEMPLATE    Template to use for nix flake init (mandatory)
    --git-name GIT_NAME        Specify the git name (optional, default: USERNAME)
    --git-email GIT_EMAIL      Specify the git email (optional, default: USERNAME@HOSTNAME)
    -h, --help                 Show this help message
```

If you are already on your target machine running NixOS, it is recommended that you set the directory to `~/.config/nixos`, as the `rebuild` script (see below) expects your configuration in this directory.

All templates work right out of the box. You only need to edit the disk partitioning script (`disks.sh`) or provide a [disko](https://github.com/nix-community/disko) configuration (`disko.nix`) in your host directory. A basic single disk partitioning script is provided. Set your disk by its ID, which comes from `ls -lAh /dev/disk/by-id`. When you are happy with your configuration, create a public Git repository to pass to the installation script (see below).

If you like, you can lock your flake before committing by running:

```bash
nix --experimental-features "nix-command flakes" flake lock
```
