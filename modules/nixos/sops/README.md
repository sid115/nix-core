# Sops

Atomic secret provisioning for NixOS based on sops.

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

### Host configuration:

No additional configuration is required. Each module's README will tell you if it uses sops and what secrets it expects.
