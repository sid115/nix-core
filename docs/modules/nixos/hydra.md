# Hydra

Hydra is a Continuous Integration service for Nix based projects.

View the [*nix-core* NixOS module on GitHub](https://github.com/sid115/nix-core/tree/master/modules/nixos/hydra).

## References

- [GitHub](https://github.com/NixOS/hydra)
- [docs](https://hydra.nixos.org/build/298331170/download/1/hydra/)
- [NixOS Wiki](https://wiki.nixos.org/wiki/Hydra)

## Setup

Create an admin user:

```bash
sudo -u hydra hydra-create-user YOU --full-name YOU --email-address 'YOU@EXAMPLE.TLD' --password-prompt --role admin
```

## Sops

Provide the following entries to your secrets.yaml for email support:

> Replace `abc123` with your actual secrets

```yaml
hydra:
    smtp-password: abc123 # for email support (local or external mailserver)
    hashed-smtp-password: abc123 # for email support (local mailserver only)
```

Generate the hashed password with:

```shell
nix-shell -p mkpasswd --run 'mkpasswd -sm bcrypt'
```

> For more info, see our mailserver module.
