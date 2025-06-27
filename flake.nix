{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-zoom.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-comfyui.url = "github:nixos/nixpkgs/pull/402112/head";

    home-manager.url = "github:nix-community/home-manager";
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

      nixpkgsFor = forAllSystems (
        system:
        import nixpkgs {
          inherit system;
          # overlays = [ self.overlays.additions ]; # FIXME: infinite recursion
        }
      );
    in
    {
      apps = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
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

      packages = forAllSystems (system: import ./pkgs { pkgs = nixpkgsFor.${system}; });

      overlays = import ./overlays { inherit inputs; };

      nixosModules = import ./modules/nixos;

      homeModules = import ./modules/home;

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          default = import ./shell.nix { inherit pkgs; };
        }
      );

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
      #     pkgs = nixpkgsFor.x86_64-linux;
      #     extraSpecialArgs = { inherit inputs outputs; };
      #     modules = [ ./tests/hm-test ];
      #   };
      # };

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);

      checks = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
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

      hydraJobs = {
        inherit (self)
          packages
          ;
      };

      templates = {
        nix-config = {
          path = ./templates/nix-config;
          description = "NixOS configuration with standalone Home Manager using nix-core.";
        };

        c-hello = {
          path = ./templates/dev/c-hello;
          description = "C hello world template.";
        };
        esp-blink = {
          path = ./templates/dev/esp-blink;
          description = "ESP32 blink template.";
        };
        py-hello = {
          path = ./templates/dev/py-hello;
          description = "Python hello world template.";
        };
        rs-hello = {
          path = ./templates/dev/rs-hello;
          description = "Rust hello world template.";
        };
      };
    };
}
