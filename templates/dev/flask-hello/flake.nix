{
  description = "A hello world template for Python Flask";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      nixpkgsFor = forAllSystems (
        system:
        import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
        }
      );
    in
    {
      overlays.default = final: _prev: {
        flask_hello = self.packages.${final.system}.default;
      };

      packages = forAllSystems (system: {
        default = nixpkgsFor.${system}.callPackage ./nix/package.nix { };
      });

      devShells = forAllSystems (system: {
        default = import ./nix/shell.nix { pkgs = nixpkgsFor.${system}; };
      });

      nixosModules = {
        flask_hello = import ./nix/module.nix;
      };

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);

      checks = forAllSystems (system: {
        build-packages = nixpkgsFor."${system}".linkFarm "flake-packages-${system}" self.packages.${system};
        pre-commit-check = self.inputs.pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            nixfmt-rfc-style.enable = true;
            black.enable = true;
          };
        };
      });
    };
}
