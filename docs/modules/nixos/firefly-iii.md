# Firefly III and Firefly III data importer

A free and open source personal finance manager.

View the [*nix-core* NixOS module on GitHub](https://github.com/sid115/nix-core/tree/master/modules/nixos/firefly-iii).

## References

- [Documentation](https://docs.firefly-iii.org/)

### Firefly III

- [GitHub](https://github.com/firefly-iii/firefly-iii)
- [Configuration example](https://github.com/firefly-iii/firefly-iii/blob/main/.env.example)

### Firefly III data importer

- [GitHub](https://github.com/firefly-iii/data-importer)
- [Configuration example](https://github.com/firefly-iii/data-importer/blob/main/.env.example)

## Sops

Provide the following entries to your host's `secrets.yaml`:

> Replace `abc123` with your actual secrets

```yaml
firefly-iii:
    appkey: abc123 # for `services.firefly-iii.settings.APP_KEY_FILE`
    smtp-password: abc123
    hashed-smtp-password: abc123
```

### Generate your app key with:

```bash
head -c 32 /dev/urandom | base64
```

### Generate the hashed SMTP password with:

```shell
nix-shell -p mkpasswd --run 'mkpasswd -sm bcrypt'
```

> For more info, see our mailserver module.

## Setup

Set CNAME records for your *Firefly III* and *Firefly III data importer* subdomains pointing to your domain.

### Firefly III

1. Visit "SUBDOMAIN.DOMAIN.TLD" in a browser.
1. Create an admin account.
1. Follow the on screen guide "Getting started".
1. Create a OAuth client for your data importer instance.
    1. Go to `Options` > `Profile` > `OAuth`
    1. Click `Create New Client`
        - Name: Can be anything
        - Redirect URL: `https://IMPORTER_SUBDOMAIN.DOMAIN.TLD/callback`
        - Confidential: **Uncheck**
    1. Click `Create`. Take note of the *Client ID*.

### Firefly III data importer

1. Visit `IMPORTER_SUBDOMAIN.DOMAIN.TLD` in a browser.
    - Firefly III URL: `https://SUBDOMAIN.DOMAIN.TLD`
    - Client ID: *Client ID* from above
1. Click `Submit`
1. Click `Authorize`
