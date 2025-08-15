{
  description = "MicroVM NixOS configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    microvm.url = "github:microvm-nix/microvm.nix";
    microvm.inputs.nixpkgs.follows = "nixpkgs";

    core.url = "github:sid115/nix-core";
    core.inputs.nixpkgs.follows = "nixpkgs";
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
      ];

      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      mkApp = program: description: {
        type = "app";
        inherit program;
        meta.description = description;
      };

      mkNixosConfiguration =
        system:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit (self) inputs outputs; };
          modules = [ ./config ];
        };
    in
    {
      apps = forAllSystems (
        system:
        let
          microvm = self.nixosConfigurations."microvm-${system}".config.microvm;
          inherit (nixpkgs.lib) getExe;
        in
        {
          rebuild = mkApp (getExe microvm.deploy.rebuild) "Rebuild the VM.";
          microvm = mkApp (getExe microvm.declaredRunner) "Run the VM.";
        }
      );

      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        import ./pkgs { inherit pkgs; }
      );

      overlays = import ./overlays { inherit (self) inputs; };

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              tmux
            ];
          };
          # FIXME: `microvm.deploy.rebuild` does not seem to care about askpass
          # shellHook = ''
          #   export SSH_ASKPASS="pass <SUDO_BUILD_HOST_PASSWORD>"
          #   export SSH_ASKPASS_REQUIRE="force"
          # '';
        }
      );

      nixosModules = import ./modules;

      nixosConfigurations = {
        microvm-x86_64-linux = mkNixosConfiguration "x86_64-linux";
        microvm-aarch64-linux = mkNixosConfiguration "aarch64-linux";
      };
    };
}
