# Headscale

Headscale is an open source, self-hosted implementation of the Tailscale control server.

View the [*nix-core* NixOS module on GitHub](https://github.com/sid115/nix-core/tree/master/modules/nixos/headscale).

## References

- [Website](https://headscale.net/stable/)
- [GitHub](https://github.com/juanfont/headscale)
- [Example configuration file](https://github.com/juanfont/headscale/blob/main/config-example.yaml)

## Setup

Set a CNAME record for your Headscale subdomain (`headscale` by default) pointing to your domain.

## Config

```nix
{
  imports = [ inputs.core.nixosModules.headscale ];

  services.headscale = {
    enable = true;
    openFirewall = true;
  };
}
```

## Usage

1.  **On the server**, create a user:
    ```bash
    sudo headscale users create <your_username>
    ```

2.  **On a client**, connect:
    ```bash
    tailscale login --login-server https://headscale.example.tld
    ```
    Then, run the displayed `headscale nodes register ...` command on the **server** to register the device.
