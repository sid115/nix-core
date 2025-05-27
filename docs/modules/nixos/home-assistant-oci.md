# Home Assistant OCI 

Open source home automation.

View the [*nix-core* NixOS module on GitHub](https://github.com/sid115/nix-core/tree/master/modules/nixos/home-assistant-oci).

## References

- [homepage](https://www.home-assistant.io/)
- [docs](https://www.home-assistant.io/docs/)

## Setup

Enable the service in your NixOS configuration:

```nix
imports = [ inputs.core.nixosModule.home-assistant-oci ];

services.home-assistant-oci.enable = true;
```

Access the web interface at `http://<ip-of-your-device>:8123`. There should be an option for creating an account.

## Auto-discovery

In case you cannot get your home devices discovered in your network, you might need to open TCP ports on your server that are required by your services via `networking.firewall.allowedTCPPorts` and add the services via *Settings >> Devices & Services >> Integrations >> Add Integration* manually in home-assistant.
