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
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      lib = pkgs.lib;
    in
    {
      apps = {
        ssh = {
          type = "app";
          program = lib.getExe (pkgs.callPackage ./apps/ssh { });
          meta.description = "SSH into the VM.";
        };
        rebuild = {
          type = "app";
          # program = lib.getExe self.nixosConfigurations.microvm.config.microvm.deploy.rebuild; # TODO: https://microvm-nix.github.io/microvm.nix/ssh-deploy.html
          meta.description = "Rebuild NixOS configuration inside VM.";
        };
        microvm = {
          type = "app";
          program = lib.getExe self.nixosConfigurations.microvm.config.microvm.declaredRunner;
          meta.description = "Run the VM.";
        };
      };

      packages = import ./pkgs { inherit pkgs; };

      overlays = import ./overlays { inherit (self) inputs; };

      nixosConfigurations = {
        microvm = lib.nixosSystem {
          inherit system;
          specialArgs = { inherit (self) inputs outputs; };
          modules = [ ./config ];
        };
      };

      nixosModules = import ./modules;
    };
}
