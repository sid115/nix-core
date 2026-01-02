# GitLab

GitLab Community Edition is an open source end-to-end software development platform with built-in version control, issue tracking, code review, CI/CD, and more.

View the [*nix-core* NixOS module on GitHub](https://github.com/sid115/nix-core/tree/master/modules/nixos/gitlab).

## References

- [Documentation](https://docs.gitlab.com/)
- [Example config file](https://gitlab.com/gitlab-org/gitlab/-/blob/master/config/gitlab.yml.example)

## Sops

Provide the following entries to your host's `secrets.yaml`:

> Replace `abc123` with your actual secrets

```yaml
gitlab:
  root-password: abc123
  secret: abc123
  db: abc123
  otp: abc123
  jws: abc123
  ar-primary: abc123
  ar-deterministic: abc123
  ar-salt: abc123
  smtp-password: abc123 # only set this if `mailIntegration` is true
```

Generate your secrets with:

```bash
nix-shell -p openssl --run "openssl rand -hex 32"
```

## Config

```nix
{
  imports = [ inputs.core.nixosModules.gitlab ];

  services.gitlab = {
        enable = true;
  };
}
```

## Setup

Login as the default admin user "root" with the password you set above and create users as you see fit.

## Administration

### Disable Sign-ups

In the web UI, navigate to:

_Admin Area_ > _Settings_ > _General_ > _Sign-up restrictions_ and uncheck _Sign-up enabled_.
