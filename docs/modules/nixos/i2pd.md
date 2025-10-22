# I2P Daemon

I2P is an End-to-End encrypted and anonymous Internet.

View the [*nix-core* NixOS module on GitHub](https://github.com/sid115/nix-core/tree/master/modules/nixos/i2pd).

## References

- [Homepage](https://i2pd.website/)
- [Documentation](https://i2pd.readthedocs.io/en/latest/)
- [GitHub](https://github.com/PurpleI2P/i2pd)
- [I2P on NixOS guide](https://voidcruiser.nl/rambles/i2p-on-nixos/)

## Configuration

### NixOS

```nix
{ inputs, ... }:

{
  imports = [ inputs.core.nixosModules.i2pd ];

  services.i2pd.enable = true;
}
```
