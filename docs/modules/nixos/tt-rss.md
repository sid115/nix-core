# Tiny Tiny RSS

A web-based news feed (RSS/Atom) reader and aggregator.

View the [*nix-core* NixOS module on GitHub](https://github.com/sid115/nix-core/tree/master/modules/nixos/tt-rss).

## References

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

## Newsboat

To be able to access your feeds in [Newsboat](https://newsboat.org/index.html), follow these steps:

### 1. Activate API access

- Log in to your TT-RSS instance.
- Click the hamburger menu in the top right corner, then select *Preferences*.
- Check *Enable API*.
- Click *Save configuration*.

### 2. Newsboat Home Manager configuration

```nix
programs.newsboat = {
  enable = true;
  extraConfig = ''
    urls-source "ttrss"
    ttrss-url "https://tt-rss.example.com/"
    ttrss-login "you"
    ttrss-passwordfile "${config.sops.secrets.tt-rss.path}"
  '';
};

sops.secrets.tt-rss = { };
```

Set `ttrss-url` and `ttrss-login`. Create an entry `tt-rss` in your sops secrets file `secrets.yaml`.
