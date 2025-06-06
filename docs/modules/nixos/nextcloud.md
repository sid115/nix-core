# Nextcloud

Nextcloud is an open source content collaboration platform and file hosting service.

View the [*nix-core* NixOS module on GitHub](https://github.com/sid115/nix-core/tree/master/modules/nixos/nextcloud).

## References

- [homepage](https://nextcloud.com/)
- [docs](https://docs.nextcloud.com/server/stable/admin_manual/)

## Setup

- Login as the default admin user "nextcloud" with the same password.
- Create a new user and add "admin" under "Groups" to make him an admin user.
- Log out and in as the new user.
- Delete the user "nextcloud".

## Sops

Provide the following entries to your secrets.yaml for email support:

> Replace `abc123` with your actual secrets

```yaml
nextcloud:
    smtp-password: abc123 # for email support (local or external mailserver)
    hashed-smtp-password: abc123 # for email support (local mailserver only)
```

Generate the hashed password with:

```shell
nix-shell -p mkpasswd --run 'mkpasswd -sm bcrypt'
```

> For more info, see our mailserver module.

## Config

### Apps

Installing apps via the web interface is disabled. You have to use `services.nextcloud.extraApps`.

Configuring them works as usual in the web interface.
