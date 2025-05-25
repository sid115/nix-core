# Vaultwarden

Unofficial Bitwarden compatible server written in Rust, formerly known as bitwarden_rs.

View the [*nix-core* NixOS module on GitHub](https://github.com/sid115/nix-core/tree/master/modules/nixos/vaultwarden).

## References

- [repo](https://github.com/dani-garcia/vaultwarden)
- [docs](https://github.com/dani-garcia/vaultwarden/wiki)

## Sops

> Replace `abc123` with your actual secrets

```yaml
vaultwarden:
    admin-token: abc123
    smtp-password: abc123 # for email support (local or external mailserver)
    hashed-smtp-password: abc123 # for email support (local mailserver only)
```

Generate the hashed smtp password with:

```shell
nix-shell -p mkpasswd --run 'mkpasswd -sm bcrypt'
```

> For more info, see our mailserver module.

Optionally, you can store your admin token as an argon2 PHC string with the OWASP minimum recommended settings in sops. It is recommended to use an alphanumeric string only, as special characters may need to be escaped:

```shell
nix-shell -p openssl libargon2 --run 'echo -n "abc123" | argon2 "$(openssl rand -base64 32)" -e -id -k 19456 -t 2 -p 1'
```

## Setup

- Visit `https://SUBDOMAIN.DOMAIN.TLD/admin` and enter the admin token.
- Click on "Users" in the top row.
- Invite users via email in the box at the bottom.
