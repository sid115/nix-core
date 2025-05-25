# Grafana

A data visualization platform. Visualize metrics, logs, and traces from multiple sources.

View the [*nix-core* NixOS module on GitHub](https://github.com/sid115/nix-core/tree/master/modules/nixos/grafana).

## References

- [docs](https://grafana.com/docs/grafana/latest/)
- [GitHub](https://github.com/grafana/grafana)

## Setup

Initial admin creation is disabled by default. Set his password by running:

```bash
sudo -u grafana grafana cli --homepath=/data/grafana admin reset-admin-password --password-from-stdin
```

> Set `--homepath` to `services.grafana.dataDir`

Login to your web interface as *admin* with the password you set earlier. Change your user info by clicking on the user icon in the top right corner.

## Dashboards

> TODO
