# Create your own nix-config flake

Create an empty directory and apply a [nix-config template](https://github.com/sid115/nix-core/tree/master/templates/nix-config) to it:

```bash
mkdir -p ~/.config/nixos
cd ~/.config/nixos
nix flake init -t "github:sid115/nix-core#templates.TEMPLATE"
```

Available templates are:
- hetzner-amd
- hyprland
- pi4
- server
- vm-uefi

> Note: You do not have to use `~/.config/nixos`, but configuration related scripts in this repository will use this directory as the default nix-config flake directory.

Alternatively, use this flake's create script:

```bash
nix run "github:sid115/nix-core#create" -- -t TEMPLATE -u YOUR_USER -h YOUR_HOSTNAME
```

Check:

```bash
nix run "github:sid115/nix-core#create" -- --help
```
