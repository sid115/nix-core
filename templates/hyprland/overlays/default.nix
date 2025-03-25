{ inputs, ... }:

{
  # nix-core packages accessible through 'pkgs.core'
  core-packages = final: prev: { core = inputs.core.packages."${final.system}"; };

  # packages in `pkgs/` accessible through 'pkgs.local'
  local-packages = final: prev: { local = import ../pkgs { pkgs = final; }; };

  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: { } // inputs.core.overlays.modifications final prev;

  # unstable nixpkgs accessible through 'pkgs.unstable'
  unstable-packages = final: prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final) system;
      inherit (prev) config;
    };
  };

  # old-stable nixpkgs accessible through 'pkgs.old'
  old-stable-packages = final: prev: {
    old = import inputs.nixpkgs-old-stable {
      inherit (final) system;
      inherit (prev) config;
    };
  };
}
