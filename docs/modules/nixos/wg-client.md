# WireGuard VPN Client

A wrapper module to connect to a WireGuard VPN server.

View the [*nix-core* NixOS module on GitHub](https://github.com/sid116/nix-core/tree/master/modules/nixos/wg-client).

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

Provide a private key for each interface in your `secrets.yaml`. You can also add a preshared key:

> Replace `abc123` with your actual secrets

```yaml
wireguard:
    wg0:
        private-key: abc123
    wg1:
        private-key: abc123
        psk: abc123
```

## Config

Here is an example configuration.

```nix
{ inputs, config, ... }:

{
  imports = [ inputs.core.nixosModules.client ];

  networking.wg-client = {
    wg0 = {
      clientAddress = "10.0.0.2";
      peer.publicIP = "12.34.56.78";
    };
    wg1 = {
      clientAddress = "10.100.0.12";
      peer = {
        publicIP = "59.51.51.211";
        internalIP = "10.100.0.1";
        presharedKeyFile = config.secrets."wireguard/wg1/psk".path;
      };
    };
  };

  sops.secrets."wireguard/wg1/psk" = { };
}
```

## Server

See the [WireGuard server module on nix-core](https://github.com/sid116/nix-core/tree/master/modules/nixos/wg-server).
