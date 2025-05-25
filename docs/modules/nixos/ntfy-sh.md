# ntfy-sh notifiers

Collection of notifiers for ntfy-sh.

View the [*nix-core* NixOS module on GitHub](https://github.com/sid115/nix-core/tree/master/modules/nixos/ntfy-sh).

## References

- [ntfy-sh docs](https://docs.ntfy.sh/)
- [GitHub repo](https://github.com/binwiederhier/ntfy)

## Setup

Import and enable the module:

### Server

```nix
imports = [ inputs.core.nixosModules.ntfy-sh ]

services.ntfy-sh = {
  enable = true;
  reverseProxy.enable = true;
  settings.base-url = "https://ntfy.example.tld";
  # add notifiers. See `default.nix`
  notifiers = {
    monitor-domains = [
      {
        fqdn = "foo.bar";
        topic = "foo-bar";
      }
    ];
  };
};
```

Add a CNAME record for *ntfy.example.tld* to point to *example.tld*.

### Client

#### Android

1. Download and install the [ntfy app](https://f-droid.org/en/packages/io.heckel.ntfy/).
2. Open the ntfy app.
3. Allow notifications for ntfy.
4. Subscribe to your topics:
    1. Click on the plus icon in the bottom right corner.
    2. Enter your topic (e.g. *foo-bar*, see server setup above).
    3. Check *Use another server*.
    4. Enter your ntfy url (`services.ntfy-sh.settings.base-url`).
    5. Click *Subscribe*.
