{
  description = "A hello world template for Python Flask";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
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
      overlays.default = final: prev: {
      };

      apps = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          mkApp = pname: desc: {
            type = "app";
            program = pkgs.lib.getExe self.packages.${system}.${pname};
            meta.description = desc;
          };
        in
        {
          default = self.apps.${system}.serve-flask;
          serve-flask = mkApp "default" "Serve the default Flask web application.";
        }
      );

      packages = forAllSystems (system: {
        default = self.packages.${system}.flask-hello;
        flask-hello = nixpkgsFor.${system}.callPackage ./package.nix { };
      });

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
          python = pkgs.python3;
        in
        {
          default = pkgs.mkShell {
            inherit (self.checks.${system}.pre-commit-check) shellHook;
            buildInputs = self.checks.${system}.pre-commit-check.enabledPackages ++ [
              (python.withPackages (
                p: with p; [
                ]
              ))
            ];
          };
        }
      );

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);

      checks = forAllSystems (system: {
        # TODO: Add integration test

        pre-commit-check = self.inputs.pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            nixfmt-rfc-style = {
              enable = true;
            };
            # TODO: Add Python format check
          };
        };
      });
    };
}
