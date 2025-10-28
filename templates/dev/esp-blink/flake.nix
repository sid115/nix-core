{
  description = "A blink template for ESP32";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    esp = {
      url = "github:mirrexagon/nixpkgs-esp-dev";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      esp,
      pre-commit-hooks,
      ...
    }:
    let
      pname = "blink"; # Also change this in CMakeLists.txt
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
          overlays = [
            self.overlays.default
            esp.overlays.default
          ];
        }
      );
    in
    {
      overlays.default = final: prev: { };

      packages = forAllSystems (system: { });

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          default = esp.devShells."${system}".default;
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
          pkgs = nixpkgsFor.${system};
          flakePkgs = self.packages.${system};
        in
        {
          build-packages = pkgs.linkFarm "flake-packages-${system}" flakePkgs;

          pre-commit-check = pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              nixfmt = {
                enable = true;
              };
              clang-format = {
                enable = true;
                types_or = nixpkgs.lib.mkForce [
                  "c"
                  "cpp"
                ];
              };
            };
          };
        }
      );
    };
}
