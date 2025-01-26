# Torrenting

> Note: This module is not actively maintained. Expect things to break!

A torrenting module for a web interface using [deluge](https://deluge-torrent.org/) and deluge-web. Check out the [user guide](https://deluge-torrent.org/userguide/).

## Setup

Visit `https://SUBDOMAIN.EXAMPLE.TLD`. The default password is `deluge`. Change it immediately after login.

## Sops

Provide the following entries to your secrets.yaml:

```yaml
deluge:
    auth: |
        localclient:PASSWORD0:10 # always add a localclient user as admin
```

Refer to the [authentication section](https://deluge-torrent.org/userguide/authentication/) for more information.
