# 2. Create your own nix-config flake

Create an empty directory and apply the [nix-config template](https://github.com/sid115/nix-core/tree/master/templates/nix-config) to it:

```bash
mkdir -p ~/.config/nixos
cd ~/.config/nixos
nix flake init -t "github:sid115/nix-core#templates.nix-config"
```

> Note: You do not have to use `~/.config/nixos`, but configuration related scripts in this repository will use this directory as the default nix-config flake directory.
