# Vaultwarden

Unofficial Bitwarden compatible server written in Rust, formerly known as bitwarden_rs.

- [repo](https://github.com/dani-garcia/vaultwarden)
- [docs](https://github.com/dani-garcia/vaultwarden/wiki)

## Setup

- Visit `https://SUBDOMAIN.DOMAIN.TLD/admin` and enter the admin token.
- Click on "Users" in the top row.
- Invite users via email in the box at the bottom.

## Sops

Provide the following entries to your secrets.yaml for email support:

> Replace `abc123` with your actual secrets

```yaml
vaultwarden:
    admin-token: abc123
    smtp-password: abc123
    hashed-smtp-password: abc123
```

Generate the hashed password with:

```shell
nix-shell -p mkpasswd --run 'mkpasswd -sm bcrypt'
```

> For more info, see our mailserver module.
