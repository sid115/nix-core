# Sops

Atomic secret provisioning for NixOS based on sops.

View the [*nix-core* NixOS module on GitHub](https://github.com/sid115/nix-core/tree/master/modules/nixos/sops).

## References

- [GitHub](https://github.com/Mic92/sops-nix)

## Setup

Generate an age key for your host from its ssh host key:

```bash
nix-shell -p ssh-to-age --run 'cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age'
```

Then, add it to `.sops.yaml` (see [usage example](https://github.com/Mic92/sops-nix?tab=readme-ov-file#usage-example)).

## Config

### Flake

```nix
# flake.nix
inputs = {
  sops-nix.url = "github:Mic92/sops-nix";
  sops-nix.inputs.nixpkgs.follows = "nixpkgs";
};
```

### Host configuration

Create a `secrets` directory in your hosts directory. Declare all your secrets in it:

```nix
# hosts/YOUR_HOST/secrets/default.nix
{ inputs, ... }:

{
  imports = [ inputs.core.nixosModules.sops ];

  sops.secrets.your-secret = { };
  sops.secrets.other-secret = { };
```

## Usage

For more information on how to use sops-nix, see the [Sops Home Manager module documentation](../home/sops.md).

## Update Keys

Update the keys of your SOPS files after making changes to `.sops.yaml`:

```bash
sops --config PATH/TO/.sops.yaml updatekeys PATH/TO/secrets.yaml
```
