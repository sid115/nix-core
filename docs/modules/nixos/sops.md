# Sops

Atomic secret provisioning for NixOS based on sops.

View the [*nix-core* NixOS module on GitHub](https://github.com/sid115/nix-core/tree/master/modules/nixos/sops).

## References

- [GitHub](https://github.com/Mic92/sops-nix)

## Config

### `flake.nix`

```nix
inputs = {
  sops-nix.url = "github:Mic92/sops-nix";
  sops-nix.inputs.nixpkgs.follows = "nixpkgs";
};
```

## Setup

Generate an age key for your host from its ssh host key:

```bash
nix-shell -p ssh-to-age --run 'cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age'
```

Then, add it to `.sops.yaml`.

### Host configuration:

No additional configuration is required. Each module's documentation entry will tell you if it uses sops and what secrets it expects.

## Update Keys

Update the keys of your SOPS files after making changes to `.sops.yaml`:

```bash
sops --config PATH/TO/.sops.yaml updatekeys PATH/TO/secrets.yaml
```
