# Peertube

PeerTube is a free and open-source, decentralized, ActivityPub federated video platform.

[docs](https://docs.joinpeertube.org/admin/configuration)

## Sops

Provide the following entries to your secrets.yaml:

> Replace `abc123` with your actual secret(s)

```yaml
peertube:
    secret: abc123
```

## Setup

Initially, rebuild with:

```nix
services.peertube.settings = {
  signup = {
    enabled = true;
    requires_approval = false;
  };
};
```

Then, create an account in the web interface. After that, rebuild with signups disabled.
