# Tiny Tiny RSS

A web-based news feed (RSS/Atom) reader and aggregator.

- [Official website](https://tt-rss.org/)
- [NixOS Wiki](https://wiki.nixos.org/wiki/Tt-rss)

## Setup

- Create a suitable CNAME record. The default subdomain is "tt-rss".
- Import this module and set `services.tt-rss.enable = true`.

## User Management

Use the provided script `tt-rss-users` to manage users.

> `tt_rss` is the default user. Check `config.services.tt-rss.user` for more details.

### Add a user

```bash
sudo -u tt_rss tt-rss-users add <username> <password>
```

### Remove a user

```bash
sudo -u tt_rss tt-rss-users remove <username>
```
