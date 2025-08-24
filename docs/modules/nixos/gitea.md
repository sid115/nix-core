# Gitea

Gitea is a forge software package for hosting software development version control using Git.

View the [*nix-core* NixOS module on GitHub](https://github.com/sid115/nix-core/tree/master/modules/nixos/gitea).

## References

- [docs](https://docs.gitea.com/)

## Administration

[cli docs](https://docs.gitea.com/administration/command-line)

> `gitea` is aliased to `sudo -u gitea gitea --config /var/lib/gitea/custom/conf/app.ini`

Add a user:

```bash
gitea admin user create -u USER -p PASSWORD --email USER@sid.ovh [--admin]
```

Change user password:

```bash
gitea admin user change-password -u USER -p PASSWORD
```
