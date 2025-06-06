# nix-serve

Standalone Nix binary cache server.

View the [*nix-core* NixOS module on GitHub](https://github.com/sid115/nix-core/tree/master/modules/nixos/nix-serve).

## References

- [NixOS Community Wiki](https://nixos.wiki/wiki/Binary_Cache)

## Setup

Generate binary cache key pair:

```bash
nix-store --generate-binary-cache-key SUBDOMAIN.EXAMPLE.TLD cache-priv-key.pem cache-pub-key.pem
```

Publishing the public key will allow anybody to use your server as a binary cache. Keep the private key secret.

## Sops

Provide the following entries to your secrets.yaml for email support:

> Replace `abc123` with your actual secrets

```yaml
hydra:
    cache-priv-key: abc123 # only the string between `:` and `==`
```

## Troubleshooting

Check the general availability of your cache server:

```bash
curl https://SUBDOMAIN.EXAMPLE.TLD/nix-cache-info
```
