# Windows OCI 

Windows inside a Docker container.

View the [*nix-core* NixOS module on GitHub](https://github.com/sid115/nix-core/tree/master/modules/nixos/windows-oci).

## References

- [dockur on GitHub](https://github.com/dockur/windows)

## Config

```nix
imports = [ inputs.core.nixosModule.windows-oci ];

services.windows-oci.enable = true;
```

## Setup

You can monitor the installation process with:

```bash
journalctl -u podman-windows.service -f
```

The first-time setup may fail. Rebooting should resolve the issue.

## Usage

Access the VNC web interface at `http://127.0.0.1:8006`. Or connect via RDP at `127.0.0.1`.

TODO: Setup Windows RemoteApp
