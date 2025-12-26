{ inputs, ... }:

{
  default = final: prev: {
    lib = prev.lib // {
      utils = import ../lib/utils.nix { lib = prev.lib; };
    };
  };

  additions = final: _prev: import ../pkgs final.pkgs;

  modifications = final: prev: {
    # https://github.com/NixOS/nixpkgs/issues/335003#issuecomment-2755803376
    kicad = (
      prev.kicad.override {
        stable = true;
      }
    );
  };
}
