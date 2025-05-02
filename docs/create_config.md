# Create NixOS and Home Manager configurations

Run the [`create` script](../apps/create/create.sh) to add your desired [configuration template](../apps/create/templates/) to your nix-config flake:

```bash
nix --experimental-features "nix-command flakes" run github:sid115/nix-core#apps.x86_64-linux.create -- \
-t TEMPLATE \
-u USERNAME \
-H HOST \
--git-name GIT_NAME \
--git-email GIT_EMAIL \
-f ~/.config/nixos
```

> Change the architecture if needed. Supported architectures are listet under `supportedSystems` inside [`flake.nix`](../flake.nix).

See the script's help page for reference:

```
Usage: create -t|--template TEMPLATE -u|--user USERNAME -H|--host HOSTNAME [-f|--flake PATH/TO/YOUR/NIX-CONFIG] [--git-name GIT_NAME] [--git-email GIT_EMAIL]

Options:
    -t, --template TEMPLATE    Configuration template to use (mandatory)
    -u, --user USERNAME        Specify the username (mandatory)
    -H, --host HOSTNAME        Specify the hostname (mandatory)
    -f, --flake FLAKE          Path to your flake directory (optional, default: ~/.config/nixos)
    --git-name GIT_NAME        Specify the git name (optional, default: USERNAME)
    --git-email GIT_EMAIL      Specify the git email (optional, default: USERNAME@HOSTNAME)
    -h, --help                 Show this help message

Available configuration templates:
    hyprland
    server
```

All templates should work right out of the box. You only need to edit the disk partitioning script (`disks.sh`) or provide a [disko](https://github.com/nix-community/disko) configuration (`disko.nix`) in your host directory. A basic single disk partitioning script is provided. Set your disk by its ID, which comes from `ls -lAh /dev/disk/by-id`.

> Warning: The create script applies patch files. It will print what it patched to stdout. It is strongly recommended to verify them manually.

If you like, you can lock your flake before committing by running:

```bash
nix --experimental-features "nix-command flakes" flake lock
```
