# Open WebUI

Open WebUI is an extensible, self-hosted AI interface that adapts to your workflow, all while operating entirely offline.

View the [*nix-core* NixOS module on GitHub](https://github.com/sid115/nix-core/tree/master/modules/nixos/open-webui).

## References

- [Homepage](https://openwebui.com/)
- [GitHub](https://github.com/open-webui/open-webui)
- [Environment Configuration](https://docs.openwebui.com/getting-started/advanced-topics/env-configuration/)

## Configuration

### NixOS

```nix
{ inputs, ... }:

{
  imports = [ inputs.core.nixosModules.open-webui ];

  services.open-webui.enable = true;
}
```

### Web-UI

- Create a new admin user.
  - Admin Panel > Dashboard > Add User
    - Role: Admin
    - Set: Name, Email, Password
  - Sign out
  - Log in with the new user
  - Admin Panel > Dashboard > Edit User `admin@localhost`
  - Admin deletion does not seem to work at the moment, see [this discussion](https://github.com/open-webui/open-webui/discussions/6128). For now, just set a password for `admin@localhost`.
- Add API keys
  - Admin Panel > Settings > Connections > OpenAI API > API KEY
  - Verify connection, then Save

## Setup

> Remember to set a CNAME record pointing to your domain.

1. Import this module:
```nix
imports = [
  inputs.core.nixosModules.open-webui
];
```
2. Rebuild your system with `ENABLE_SIGNUP = "True";`:
```nix
services.open-webui = {
  enable = true;
  environment.ENABLE_SIGNUP = "True"; # Delete this in step 5
};
```
3. Visit `SUBDOMAIN.DOMAIN.TLD`.
4. Click on "Sign up" to create an admin account.
5. Disable signups and rebuild.

## Troubleshooting

### JSON parse error

If you get this error in the web interface:

```
SyntaxError: Unexpected token 'd', "data: {"id"... is not valid JSON category
```

Clear your browser cache. Steps on Chromium based browsers:

1. Open DevTools (F12) → Right-click refresh button
1. Click "Empty Cache and Hard Reload"
