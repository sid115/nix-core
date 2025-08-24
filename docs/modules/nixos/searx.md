# Searx

Searx is a free and open-source metasearch engine.

View the [*nix-core* NixOS module on GitHub](https://github.com/sid115/nix-core/tree/master/modules/nixos/rss-bridge).

## References

- [docs](https://searx.github.io/searx/)
- [settings.yml](https://dalf.github.io/searxng/admin/engines/settings.html)

## Sops

Provide the following entries to your secrets.yaml:

> Replace `abc123` with your actual secrets

```yaml
searx:
    secret-key: abc123
```
