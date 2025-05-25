# Apache Guacamole

> Warning: This module is not actively maintained. Expect things to break!

Apache Guacamole is a clientless remote desktop gateway.

View the [*nix-core* NixOS module on GitHub](https://github.com/sid115/nix-core/tree/master/modules/nixos/guacamole).

## References

- [docs](https://guacamole.apache.org/doc/gug/)

## Config

```nix
services.guacamole = {
  enable = true;
  users = ./path/to/user-mapping.xml;
  settings = {
    guacd-hostname = "localhost";
    guacd-port = 4822;
    guacd-ssl = false;
  };
};
```
