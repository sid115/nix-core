# Matrix-Synapse

Synapse is a [Matrix](https://matrix.org/) homeserver. Matrix is an open network for secure, decentralised communication.

View the [*nix-core* NixOS module on GitHub](https://github.com/sid115/nix-core/tree/master/modules/nixos/matrix-synapse).

## References

- [repo](https://github.com/element-hq/synapse)
- [docs](https://matrix-org.github.io/synapse/latest/welcome_and_overview.html)
- [coturn](https://github.com/coturn/coturn)

## Setup

### DNS

Make sure you have a CNAME record for `turn` pointing to your domain.

### Sops

Provide the following entries to your secrets.yaml:

> Replace `abc123` with your actual secret(s)

```yaml
coturn:
    static-auth-secret: abc123
matrix:
    registration-shared-secret: abc123
livekit:
    key: abc123
```
Generate the livekit key with:

```bash
nix-shell -p livekit --run "livekit-server generate-keys | tail -1 | awk '{print $3}'"
```

## Config

```nix
{
  imports = [inputs.core.nixosModules.matrix-synapse ];

  networking.domain = "example.tld";
  
  services.matrix-synapse = {
    enable = true;
    # see below
    bridges = {
      whatsapp = {
        enable = true;
        admin = "@you:example.tld";
      };
      signal = {
        enable = true;
        admin = "@you:example.tld";
      };
    };
  };
}
```

## Bridges

> Warning: Bridges use [`mautrix-go`](https://github.com/mautrix/go) which relies on [deprecated `libolm`](https://github.com/mautrix/go/issues/262).

### Sops

Provide the following entries to your secrets.yaml:

> Replace `abc123` with your actual secret(s) and `BRIDGE` with the name of your bridge (e.g., `whatsapp` or `signal`)

```yaml
mautrix-BRIDGE:
    encryption-pickle-key: abc123
    provisioning-shared-secret: abc123
    public-media-signing-key: abc123
    direct-media-server-key: abc123
```

Generate the secrets with:

```bash
nix-shell -p openssl --run "openssl rand -base64 32"
```

### NixOS configuration

The `config.yaml` for each bridge is managed through `services.mautrix-BRIDGE.settings`:

- [services.mautrix-signal.settings](https://search.nixos.org/options?channel=unstable&query=services.mautrix-signal.settings): Generate an example config with: `mautrix-signal -c signal.yaml --generate-example-config`
- [services.mautrix-whatsapp.settings](https://search.nixos.org/options?channel=unstable&query=services.mautrix-whatsapp.settings): Generate an example config with: `mautrix-whatsapp -c whatsapp.yaml --generate-example-config`

### Authentication

1. Open chat with bridge bot: `@BOT:DOMAIN.TLD`
    - WhatsApp: `whatsappbot`
    - Signal: `signalbot`
1. Send: `login qr`
1. Scan QR code
1. Switch puppets: `login-matrix ACCESS_TOKEN`
    - Get your token with: Settings > Help & About > Advanced > Access Token

## Administration

### Register users

```bash
register_new_matrix_user -u USERNAME -p PASSWORD
```

## Troubleshooting

### Bridges: Specified admin user is not an admin in portal rooms

There seems to be a bug that the user specified under `services.matrix-synapse.bridges.whatsapp.admin` does not have admin permissions in portal rooms. You can set the power level manually inside each portal room:

```plaintext
!wa set-pl @YOU:DOMAIN.TLD 100
```
