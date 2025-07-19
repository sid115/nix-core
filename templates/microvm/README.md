# microvm

[microvm](https://github.com/microvm-nix/microvm.nix) NixOS configuration.

Run VM:

```bash
nix run .#microvm
```

SSH into VM:

```bash
nix run .#ssh
```

Rebuild NixOS configuration inside VM:

```bash
nix run .#rebuild # WIP
```
