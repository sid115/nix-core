{
  description = "A hello world template in Python";

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
      pname = "hello-world";
      version = "0.1.0";

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
      overlays.default =
        final: prev:
        let
          python = final.python312;
        in
        {
          "${pname}" = python.pkgs.buildPythonApplication {
            inherit pname version;
            pyproject = true;
            src = ./.;
            build-system = [
              python.pkgs.setuptools
              python.pkgs.wheel
            ];
            dependencies = with python.pkgs; [
            ];
            pythonImportsCheck = [
              "hello_world"
            ];
          };
        };

      packages = forAllSystems (system: {
        default = nixpkgsFor.${system}."${pname}";
        "${pname}" = nixpkgsFor.${system}."${pname}";
      });

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
          python = pkgs.python312;
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

          venv = pkgs.mkShell {
            buildInputs = [
              python
            ]
            ++ [
              (python.withPackages (
                p: with p; [
                  pip
                ]
              ))
            ];
            shellHook = ''
              python -m venv .venv
              source .venv/bin/activate
              pip install .
            '';
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

      checks = forAllSystems (system: {
        # TODO: Add integration test

        pre-commit-check = self.inputs.pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            nixfmt = {
              enable = true;
            };
            # TODO: Add Python format check
          };
        };
      });
    };
}
