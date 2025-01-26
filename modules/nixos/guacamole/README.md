# Apache Guacamole

> Note: This module is not actively maintained. Expect things to break!

Apache Guacamole is a clientless remote desktop gateway.

- [docs](https://guacamole.apache.org/doc/gug/)

## Config

```nix
config.services.guacamole = {
  enable = true;
  users = ./path/to/user-mapping.xml;
  settings = {
    guacd-hostname = "localhost";
    guacd-port = 4822;
    guacd-ssl = false;
  };
};
```
