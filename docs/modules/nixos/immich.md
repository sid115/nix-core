# Immich

Self-hosted photo and video management solution.

View the [*nix-core* NixOS module on GitHub](https://github.com/sid115/nix-core/tree/master/modules/nixos/immich).

## References

- [GitHub](https://github.com/immich-app/immich)
- [Docs](https://docs.immich.app/overview/quick-start/)
- [Default config file](https://docs.immich.app/install/config-file/)

## Sops

Provide the following entries to your secrets.yaml:

> Replace `abc123` with your actual secrets

```yaml
immich:
    db-pasword: abc123
```

## Setup

Set a CNAME record for your Immich subdomain (`gallery` by default) pointing to your domain.

## Config

```nix
{ inputs, ... }:

{
  imports = [ inputs.core.nixosModules.immich ];

  services.immich = {
    enable = true;
  };
}
```

## First launch

Visit the web interface to create an admin account.
