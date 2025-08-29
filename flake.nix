{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-zoom.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-ncmpcpp.url = "github:nixos/nixpkgs/b47d4f01d4213715a1f09b999bab96bb6a5b675e"; # https://hydra.nixos.org/build/302425768

    # TODO: Implement test configs for runtime checks.
    # home-manager.url = "github:nix-community/home-manager";
    # home-manager.inputs.nixpkgs.follows = "nixpkgs";

    git-hooks.url = "github:cachix/git-hooks.nix";
    git-hooks.inputs.nixpkgs.follows = "nixpkgs";
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

      src = builtins.filterSource (
        path: type: type == "directory" || nixpkgs.lib.hasSuffix ".nix" (baseNameOf path)
      ) ./.;
      ls = dir: nixpkgs.lib.attrNames (builtins.readDir (src + "/${dir}"));
      fileList = dir: map (file: ./. + "/${dir}/${file}") (ls dir);
    in
    {
      apps = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          mkApp = name: desc: {
            type = "app";
            program = pkgs.lib.getExe (pkgs.callPackage ./apps/${name} { });
            meta.description = desc;
          };
        in
        {
          install = mkApp "install" "Install a NixOS configuration.";
          create = mkApp "create" "Create a new NixOS configuration.";
          update-packages = mkApp "update-packages" "Update all packages in this flake.";
        }
      );

      packages = forAllSystems (system: import ./pkgs { pkgs = nixpkgs.legacyPackages.${system}; });

      overlays = import ./overlays { inherit inputs; };

      nixosModules = import ./modules/nixos;
      nixosModule =
        { config, lib, ... }:
        {
          _module.args.libS = lib.mkOverride 1000 (self.lib { inherit lib config; });
          imports = fileList "modules/nixos";
        };

      homeModules = import ./modules/home;

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default =
            let
              inherit (self.checks.${system}.pre-commit-check) shellHook enabledPackages;
            in
            pkgs.mkShell {
              inherit shellHook;
              nativeBuildInputs = [
                enabledPackages
              ]
              ++ (with pkgs; [
                (python313.withPackages (
                  p: with p; [
                    mkdocs
                    mkdocs-material
                    mkdocs-material-extensions
                    pygments
                  ]
                ))
              ]);
            };
        }
      );

      # TODO: Implement test configs for runtime checks.
      # nixosConfigurations = {
      #   nixos-test = nixpkgs.lib.nixosSystem {
      #     specialArgs = { inherit inputs outputs; };
      #     modules = [ ./tests/nixos-test ];
      #   };
      # };

      # TODO: Implement test configs for runtime checks.
      # homeConfigurations = {
      #   hm-test = home-manager.lib.homeManagerConfiguration {
      #     pkgs = nixpkgs.legacyPackages.x86_64-linux;
      #     extraSpecialArgs = { inherit inputs outputs; };
      #     modules = [ ./tests/hm-test ];
      #   };
      # };

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);

      checks = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          flakePkgs = self.packages.${system};
        in
        {
          pre-commit-check = inputs.git-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              # TODO: Change to nixfmt-tree when git-hooks supports it
              nixfmt-rfc-style = {
                enable = true;
                package = pkgs.nixfmt-tree;
                entry = "${pkgs.nixfmt-tree}/bin/treefmt --no-cache";
              };
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

        microvm = {
          path = ./templates/microvm;
          description = "MicroVM NixOS configurations";
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
