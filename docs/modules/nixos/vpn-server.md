# VPN Server

> WIP

A wrapper module for WireGuard to set up a VPN server.

View the [*nix-core* NixOS module on GitHub](https://github.com/sid116/nix-core/tree/master/modules/nixos/vpn-server).

## References

- [NixOS Wiki](https://wiki.nixos.org/wiki/WireGuard)

## Setup

Generate a WireGuard public private key pair:

```bash
nix-shell -p wireguard-tools --run "wg genkey | tee privkey | wg pubkey > pubkey"
```

This will create two files: `privkey` and `pubkey`.

## Sops

Provide the following entries to your secrets.yaml:

> Replace `abc124` with your actual secrets

```yaml
wireguard:
    private-key: abc124
```

## Client Config

### Network Manager

Create a public private key pair for your client as shown in _Setup_.

Create a temporary configuration file:

```
[Interface]
Address = CLIENT_IP/32
DNS = 8.8.8.8
PrivateKey = CLIENT_PRIVATE_KEY

[Peer]
PublicKey = SERVER_PUBLIC_KEY
Endpoint = SERVER_IP:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
```

Replace `CLIENT_IP`, `CLIENT_PRIVATE_KEY`, `SERVER_PUBLIC_KEY`, and `SERVER_IP` accordingly.

Apply the configuration file:

```bash
nmcli connection import type wireguard file PATH/TO/CONFIG_FILE
```
