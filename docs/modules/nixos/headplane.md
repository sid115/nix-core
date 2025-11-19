# Headplane

A feature-complete Web UI for Headscale.

View the [*nix-core* NixOS module on GitHub](https://github.com/sid115/nix-core/tree/master/modules/nixos/headplane).

## References

- [Website](https://headplane.net)
- [GitHub](https://github.com/tale/headplane)
- [NixOS options](https://headplane.net/NixOS-options)

## Sops

Provide the following entries to your `secrets.yaml`:

> Replace `abc123` with your actual secrets

```yaml
headplane:
    cookie_secret: abc123
    agent_pre_authkey: abc123
```

Generate your cookie secret with:

```bash
nix-shell -p openssl --run "openssl rand -hex 16"
```

Generate your agent pre-authkey with:

```bash
sudo headscale users create headplane-agent
sudo headscale users list # get headplane-agent user id
sudo headscale preauthkeys create --expiration 99y --reusable --user <HEADPLANE-AGENT-ID>
```

## Setup

Set a CNAME record for your Headplane subdomain (`headplane` by default) pointing to your domain.

## Config

```nix
# flake.nix
headplane.url = "github:tale/headplane";
headplane.inputs.nixpkgs.follows = "nixpkgs";
```

```nix
# configuration.nix
{
  imports = [ inputs.core.nixosModules.headplane ];

  services.headplane = {
    enable = true;
  };
}
```

## Usage

Create a Headscale API key:

```bash
sudo headscale apikeys create
```

Visit the admin login page: `https://sub.domain.tld/admin/login`
