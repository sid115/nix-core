# Miniflux

 Miniflux is a minimalist and opinionated feed reader.

View the [*nix-core* NixOS module on GitHub](https://github.com/sid115/nix-core/tree/master/modules/nixos/miniflux).

## References

- [Website](https://miniflux.app/)
- [GitHub](https://github.com/miniflux/v2)
- [Configuration parameters](https://miniflux.app/docs/configuration.html)

## Setup

### DNS

Make sure you have a CNAME record for Miniflux's subdomain (`rss` by default) pointing to your domain.

### Sops

Provide the following entries to your secrets.yaml:

> Replace `abc123` with your actual secret(s)

```yaml
miniflux:
    admin-password: abc123
```

## Config

```nix
{
  imports = [inputs.core.nixosModules.miniflux ];

  services.miniflux = {
    enable = true;
    reverseProxy.enable = true;
    reverseProxy.subdomain = "rss";
  };
}
```
