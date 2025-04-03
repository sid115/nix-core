{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-zoom.url = "github:nixos/nixpkgs/nixos-24.05";

    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    pre-commit-hooks.url = "github:cachix/git-hooks.nix";
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
        "aarch64-linux"
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

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);

      checks = forAllSystems (system: {
        pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            nixfmt-rfc-style.enable = true;
          };
        };
      });

      templates = {
        hyprland = {
          path = ./templates/hyprland;
          description = "NixOS client configuration for Hyprland.";
        };
        server = {
          path = ./templates/server;
          description = "Minimal NixOS server configuration.";
        };
        c-hello = {
          path = ./templates/c-hello;
          description = "C hello world project.";
        };
        py-hello = {
          path = ./templates/py-hello;
          description = "Python hello world project.";
        };
        rs-hello = {
          path = ./templates/rs-hello;
          description = "Rust hello world project.";
        };
      };
    };
}
