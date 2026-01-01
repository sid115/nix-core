{
  description = "Container NixOS configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    core.url = "github:sid115/nix-core";
    core.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }@inputs:
    let
      inherit (self) outputs;

      system = "x86_64-linux";

      overlays = [ inputs.core.overlays.default ];
    in
    {
      packages =
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        import ./pkgs { inherit pkgs; };

      overlays = import ./overlays { inherit (self) inputs; };

      devShells =
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              nixos-container
              tmux
            ];
          };
        };

      nixosModules = import ./modules;

      nixosConfigurations = {
        container = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [ ./config ];
          specialArgs = {
            inherit inputs outputs;
            lib =
              (import nixpkgs {
                inherit system overlays;
              }).lib;
          };
        };
      };
    };
}
