# Uptime Kuma Agent

Monitor systemd services via Uptime Kuma's push URLs.

View the [*nix-core* NixOS module on GitHub](https://github.com/sid115/nix-core/tree/master/modules/nixos/uptime-kuma-agent).

## Setup

You need a running Uptime Kuma instance to push status updates to. See the [Uptime Kuma NixOS module](https://github.com/sid115/nix-core/tree/master/modules/nixos/uptime-kuma).

Add a new monitor. Set:

- Monitor Type: Push

Copy the Push URL without its params, e.g.: `https://kuma.domain.tld/api/push/3LsNQqO4V8`

Put this URL into the monitor's `secretFile` (see below).

## Config

```nix
{
  imports = [ inputs.core.nixosModules.uptime-kuma-agent ];

  services.uptime-kuma-agent = {
    enable = true;
    monitors = {
      example = {
        secretFile = config.sops.secrets."uptime-kuma-agent/example".path;
      };
    };
  };

  sops.secrets."uptime-kuma-agent/example".path = { };
}
```
