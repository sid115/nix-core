# Tailscale

Private WireGuard networks made easy.

View the [*nix-core* NixOS module on GitHub](https://github.com/sid115/nix-core/tree/master/modules/nixos/tailscale).

## References

- [Website](https://tailscale.com/)
- [GitHub](https://github.com/tailscale/tailscale)
- [Documents](https://tailscale.com/kb/1017/install)

## Sops

Provide the following entries to your `secrets.yaml`:

> Replace `abc123` with your actual secrets

```yaml
tailscale:
    auth-key: abc123
```

## Config

```nix
{
  imports = [ inputs.core.nixosModules.tailscale ];

  services.tailscale = {
    enable = true;
    enableSSH = true;
    loginServer = "<your-headscale-instance>";
  };
}
```
