# WireGuard VPN Server

A wrapper module for WireGuard to set up a VPN server.

View the [*nix-core* NixOS module on GitHub](https://github.com/sid116/nix-core/tree/master/modules/nixos/wg-server).

## References

- [NixOS Wiki](https://wiki.nixos.org/wiki/WireGuard)
- [Arch Wiki](https://wiki.archlinux.org/title/WireGuard)
- [WireGuard Website](https://www.wireguard.com/)

## Setup

Generate a WireGuard public private key pair:

```bash
nix-shell -p wireguard-tools --run "wg genkey | tee privkey | wg pubkey > pubkey"
```

This will create two files: `privkey` and `pubkey`.

## Sops

Provide the following entries to your `secrets.yaml`:

> Replace `abc124` with your actual secrets

```yaml
wireguard:
    private-key: abc124
```

## Config

Here is an example configuration.

```nix
{ inputs, ... }:

{
  imports = [ inputs.core.nixosModules.wg-server ];

  networking.wg-server = {
    enable = true;
    openFirewall = true;
    externalInterface = "enp1s0";
    peers = {
      "you@your-client" = {
        publicKey = "pckrA7asNfa5AyGnAG/UWgl6PZDFO+cLtWVbuhw3pH0=";
        allowedIP = "10.100.0.2";
      };
    };
  };
}
```

## Client

See the [WireGuard client module on nix-core](https://github.com/sid116/nix-core/tree/master/modules/nixos/wg-client).
