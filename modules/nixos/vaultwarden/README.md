# Vaultwarden

Unofficial Bitwarden compatible server written in Rust, formerly known as bitwarden_rs.

- [repo](https://github.com/dani-garcia/vaultwarden)
- [docs](https://github.com/dani-garcia/vaultwarden/wiki)

## Sops

> Replace `abc123` with your actual secrets

```yaml
vaultwarden:
    admin-token: abc123
    smtp-password: abc123 # for email support
    hashed-smtp-password: # see above
```

(Optional) Store your admin-token as argon2 PHC string with the OWASP minimum recommended settings in sops. Don't use special characters unless you know how to escape them correctly, just letters and numbers:

```shell
nix-shell -p openssl -p libargon2 --run 'echo -n "MyAdminToken" | argon2 "$(openssl rand -base64 32)" -e -id -k 19456 -t 2 -p 1'
```

Generate the hashed smtp password with:

```shell
nix-shell -p mkpasswd --run 'mkpasswd -sm bcrypt'
```

> For more info, see our mailserver module.

## Setup

- Visit `https://SUBDOMAIN.DOMAIN.TLD/admin` and enter the admin token.
- Click on "Users" in the top row.
- Invite users via email in the box at the bottom.

