# Open WebUI OCI

Open WebUI is an extensible, self-hosted AI interface that adapts to your workflow, all while operating entirely offline.

View the [*nix-core* NixOS module on GitHub](https://github.com/sid115/nix-core/tree/master/modules/nixos/open-webui-oci).

## References

- [Homepage](https://openwebui.com/)
- [GitHub](https://github.com/open-webui/open-webui)
- [Environment Configuration](https://docs.openwebui.com/getting-started/env-configuration/)

## Configuration

```nix
{ inputs, ... }:

{
  imports = [ inputs.core.nixosModules.open-webui-oci ];

  services.open-webui-oci.enable = true;
}
```

## Usage

Visit the web interface at your specified location to create an admin account.

> The default location is `http://127.0.0.1:8080`.

## Troubleshooting

### JSON parse error

If you get this error in the web interface:

```
SyntaxError: Unexpected token 'd', "data: {"id"... is not valid JSON category
```

Clear your browser cache. Steps on Chromium based browsers:

1. Open DevTools (F12) → Right-click refresh button
1. Click "Empty Cache and Hard Reload"
