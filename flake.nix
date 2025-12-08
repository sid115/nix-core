{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

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

      packages = forAllSystems (
        system:
        let
          allArchs = import ./pkgs { pkgs = nixpkgs.legacyPackages.${system}; };
          x64only =
            if system == "x86_64-linux" then
              {
              }
            else
              { };
        in
        allArchs // x64only
      );

      overlays = import ./overlays { inherit inputs; };

      nixosModules = import ./modules/nixos;

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

      formatter = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          config = self.checks.${system}.pre-commit-check.config;
          inherit (config) package configFile;
          script = ''
            ${pkgs.lib.getExe package} run --all-files --config ${configFile}
          '';
        in
        pkgs.writeShellScriptBin "pre-commit-run" script
      );

      checks = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          flakePkgs = self.packages.${system};
          overlaidPkgs = import nixpkgs {
            inherit system;
            overlays = [ self.overlays.modifications ];
          };
        in
        {
          pre-commit-check = inputs.git-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              nixfmt.enable = true;
            };
          };
          build-packages = pkgs.linkFarm "flake-packages-${system}" flakePkgs;
          build-overlays = pkgs.linkFarm "flake-overlays-${system}" {
            kicad = overlaidPkgs.kicad;
          };
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
        flask-hello = {
          path = ./templates/dev/flask-hello;
          description = "Python Flask hello template.";
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
