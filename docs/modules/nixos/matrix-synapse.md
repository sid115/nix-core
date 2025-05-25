# Matrix-Synapse

Synapse is a [Matrix](https://matrix.org/) homeserver. Matrix is an open network for secure, decentralised communication.

View the [*nix-core* NixOS module on GitHub](https://github.com/sid115/nix-core/tree/master/modules/nixos/matrix-synapse).

## References

- [repo](https://github.com/element-hq/synapse)
- [docs](https://matrix-org.github.io/synapse/latest/welcome_and_overview.html)
- [coturn](https://github.com/coturn/coturn)

## Register users

```bash
register_new_matrix_user -u USERNAME -p PASSWORD
```

## Sops

Provide the following entries to your secrets.yaml:

> Replace `abc123` with your actual secret(s)

```yaml
coturn:
    static-auth-secret: abc123
matrix:
    registration-shared-secret: abc123
```

## DNS

Make sure you have a CNAME record for `turn` pointing to your domain.

## Bridges

> Warning: Bridges use [`mautrix-go`](https://github.com/mautrix/go) which relies on [deprecated `libolm`](https://github.com/mautrix/go/issues/262).

### NixOS configuration

The `config.yaml` for each bridge is managed through `services.mautrix-BRIDGE.settings`:

- [services.mautrix-signal.settings](https://search.nixos.org/options?channel=unstable&query=services.mautrix-signal.settings): [example configuration file](https://github.com/mautrix/signal/blob/main/pkg/connector/example-config.yaml)
- [services.mautrix-whatsapp.settings](https://search.nixos.org/options?channel=unstable&query=services.mautrix-whatsapp.settings): [example configuration file](https://github.com/mautrix/whatsapp/blob/main/pkg/connector/example-config.yaml)

### Authentication

1. Open chat with bridge bot: `@BOT:DOMAIN.TLD`
    - WhatsApp: `whatsappbot`
    - Signal: `signalbot`
1. Send: `login qr`
1. Scan QR code
1. Switch puppets: `login-matrix ACCESS_TOKEN`
    - Get your token with: Settings > Help & About > Advanced > Access Token

## Troubleshooting

### Specified admin user is not an admin in portal rooms

There seems to be a bug that the user specified under `services.matrix-synapse.bridges.whatsapp.admin` does not have admin permissions in portal rooms. You can set the power level manually inside each portal room:

```plaintext
!wa set-pl @YOU:DOMAIN.TLD 100
```
