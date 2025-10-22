# Radicale

A simple CalDAV and CardDAV server.

View the [*nix-core* NixOS module on GitHub](https://github.com/sid115/nix-core/tree/master/modules/nixos/radicale).

## References

- [Documentation](https://radicale.org/v3.html#documentation-1)
- [Wiki](https://github.com/Kozea/Radicale/wiki)
- [GitHub](https://github.com/Kozea/Radicale)

## Sops

Provide every user's SHA512 hashed password to your host's `secrets.yaml`:

> Replace `abc123` with your actual secrets

```yaml
radicale:
    user1: abc123
    user2: abc123
    # ...
```

Generate hashed passwords with:

```sh
nix-shell -p openssl --run 'openssl passwd -6 <password>'
```

## Setup

Set a CNAME record for your Radicale subdomain (`dav` by default) pointing to your domain.

## Config

```nix
{ inputs, ... }:

{
  imports = [ inputs.core.nixosModules.radicale ];

  services.radicale = {
    enable = true;
    users = [
      "user1"
      "user2"
    ];
  };
}
```
