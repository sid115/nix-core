{
  description = "MicroVM NixOS configurations";

  nixConfig = {
    extra-substituters = [ "https://microvm.cachix.org" ];
    extra-trusted-public-keys = [ "microvm.cachix.org-1:oXnBc6hRE3eX5rSYdRyMYXnfzcCxC7yKPTbZXALsqys=" ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    microvm.url = "github:microvm-nix/microvm.nix";
    microvm.nixpkgs.follows = "nixpkgs";

    core.url = "github:sid115/nix-core";
    core.nixpkgs.follows = "nixpkgs";
  };
  outputs =
    {
      self,
      nixpkgs,
    }@inputs:
    let
      inherit (self) outputs;

      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      mkNixosConfiguration =
        system:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs outputs; };
          modules = [
            ./config
          ];
        };
    in
    {
      packages = forAllSystems (system: {
        microvm-x86_64 = self.nixosConfigurations.microvm-x86_64.config.microvm.declaredRunner;
        microvm-aarch64 = self.nixosConfigurations.microvm-aarch64.config.microvm.declaredRunner;
      });

      nixosConfigurations = {
        microvm-x86_64 = mkNixosConfiguration "x86_64-linux";
        microvm-aarch64 = mkNixosConfiguration "aarch64-linux";
      };
    };
}
