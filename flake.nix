{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-zoom.url = "github:nixos/nixpkgs/nixos-24.05";

    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    pre-commit-hooks.url = "github:cachix/git-hooks.nix";
    pre-commit-hooks.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux" # For testing only. Use at your own risk.
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      apps = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          install = {
            type = "app";
            program =
              let
                pkg = pkgs.callPackage ./apps/install { };
              in
              "${pkg}/bin/install";
            meta.description = "Install a NixOS configuration.";
          };
          create = {
            type = "app";
            program =
              let
                pkg = pkgs.callPackage ./apps/create { };
              in
              "${pkg}/bin/create";
            meta.description = "Create a new NixOS configuration.";
          };
        }
      );

      packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});

      overlays = import ./overlays { inherit inputs; };

      nixosModules = import ./modules/nixos;
      homeModules = import ./modules/home;

      # TODO
      # nixosConfigurations = {
      #   nixos-test = nixpkgs.lib.nixosSystem {
      #     specialArgs = { inherit inputs outputs; };
      #     modules = [ ./tests/nixos-test ];
      #   };
      # };

      # TODO
      # homeConfigurations = {
      #   hm-test = home-manager.lib.homeManagerConfiguration {
      #     pkgs = nixpkgs.legacyPackages.x86_64-linux;
      #     extraSpecialArgs = { inherit inputs outputs; };
      #     modules = [ ./tests/hm-test ];
      #   };
      # };

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);

      checks = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          flakePkgs = self.packages.${system};
        in
        {
          pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              nixfmt-rfc-style.enable = true;
            };
          };
          build-packages = pkgs.linkFarm "flake-packages-${system}" flakePkgs;
        }
      );

      templates = {
        # nix-config
        hyprland = {
          path = ./templates/nix-config/hyprland;
          description = "NixOS client configuration for Hyprland.";
        };
        server = {
          path = ./templates/nix-config/server;
          description = "Minimal NixOS server configuration.";
        };

        # dev
        c-hello = {
          path = ./templates/dev/c-hello;
          description = "C hello world project.";
        };
        py-hello = {
          path = ./templates/dev/py-hello;
          description = "Python hello world project.";
        };
        rs-hello = {
          path = ./templates/dev/rs-hello;
          description = "Rust hello world project.";
        };
      };
    };
}
