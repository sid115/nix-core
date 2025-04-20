{
  description = "A hello world template in Rust";

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
      overlays.default = final: prev: {
        "${pname}" = final.rustPlatform.buildRustPackage {
          inherit pname version;
          src = ./.;
          cargoLock.lockFile = ./Cargo.lock;
          nativeBuildInputs = with final; [ pkg-config ];
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
        in
        {
          default = pkgs.mkShell {
            inherit (self.checks.${system}.pre-commit-check) shellHook;
            buildInputs =
              self.checks.${system}.pre-commit-check.enabledPackages
              ++ (with pkgs; [
                cargo
                pkg-config
                pre-commit
                rust-analyzer
                rustc
              ]);
          };
        }
      );

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);

      checks = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          integration-test =
            pkgs.runCommand "hello-world-test"
              {
                nativeBuildInputs = [
                  pkgs.coreutils
                  self.packages.${system}.${pname}
                ];
              }
              ''
                output=$(hello-world)

                echo "$output" | grep -q "Hello, World!" || {
                  echo "Test failed: Expected 'Hello, World!' but got: $output"
                  exit 1
                }

                echo "Hello World test passed!" > $out
              '';

          pre-commit-check = self.inputs.pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              nixfmt-rfc-style = {
                enable = true;
              };
              rustfmt = {
                enable = true;
              };
            };
          };
        }
      );
    };
}
