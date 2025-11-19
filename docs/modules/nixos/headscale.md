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

Create a new user:

```bash
sudo headscale users create <USER>
```

Get the user's id:

```bash
sudo headscale users list
```

Create a pre auth key for that user:

```bash
sudo headscale preauthkeys create --expiration 99y --reusable --user <ID>
```

Give the user the pre-auth key.

## Troubleshooting

Check if your ACL config is valid:

```bash
sudo headscale policy check --file PATH/TO/acl.hujson
```
