{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      apps = forAllSystems (
        system:
        let
          pkg = self.outputs.packages.${system}.default;
        in
        {
          default = {
            type = "app";
            program = "${pkg}/bin/${pkg.pname}";
          };
        }
      );

      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.callPackage ./package.nix { };
        }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = import ./shell.nix { inherit pkgs; };

          venv = pkgs.mkShell {
            buildInputs = [
              pkgs.python3
              pkgs.python3Packages.pip
            ];

            shellHook = ''
              python -m venv .venv
              source .venv/bin/activate
              pip install .
            '';
          };
        }
      );
    };
}
