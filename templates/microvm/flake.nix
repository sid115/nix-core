{
  description = "MicroVM NixOS configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    microvm.url = "github:microvm-nix/microvm.nix";
    microvm.inputs.nixpkgs.follows = "nixpkgs";

    core.url = "github:sid115/nix-core";
    core.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      mkNixosConfiguration =
        system:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit (self) inputs outputs; };
          modules = [ ./config ];
        };
    in
    {
      packages = forAllSystems (
        system:
        import ./pkgs { pkgs = nixpkgs.legacyPackages.${system}; }
        // {
          microvm-x86_64 = self.nixosConfigurations.microvm-x86_64.config.microvm.declaredRunner;
          microvm-aarch64 = self.nixosConfigurations.microvm-aarch64.config.microvm.declaredRunner;
        }
      );

      overlays = import ./overlays { inherit (self) inputs; };

      nixosConfigurations = {
        microvm-x86_64 = mkNixosConfiguration "x86_64-linux";
        microvm-aarch64 = mkNixosConfiguration "aarch64-linux";
      };

      nixosModules = import ./modules;
    };
}
