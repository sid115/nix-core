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

## Maintenance

### Admin CLI

Use Nextcloud's `occ` command for server operations. On NixOS, it is available under the wrapper script `nextcloud-occ`. Refer to the [Nextcloud docs](https://docs.nextcloud.com/server/latest/admin_manual/occ_command.html) on how to use the `occ` command, especially the [Maintenance commands](https://docs.nextcloud.com/server/latest/admin_manual/occ_command.html#maintenance-commands). Here are some useful commands:

- General housekeeping: `sudo nextcloud-occ maintenance:repair --include-expensive`

### Logging

Nextcloud's logs are handled through systemd. Relevant services are:

- `phpfpm-nextcloud.service`: PHP-FPM processes that run the Nextcloud application code - application-level logs
- `nextcloud-cron.service`: Runs Nextcloud's background jobs and maintenance tasks - cron job execution logs
- `nginx.service`: Web server that handles HTTP requests - access and connection logs

You can check these logs with:

```bash
journalctl -u SERVICE
```

These flags might be useful:

- `-p err`: Show only error-level messages and above
- `-f`: Follow logs in real-time
- `--since today`: Show logs from today onwards
