{ inputs, ... }:

{
  additions = final: _prev: import ../pkgs final.pkgs;

  modifications = final: prev: {
    # https://github.com/NixOS/nixpkgs/issues/335003#issuecomment-2755803376
    kicad = (
      prev.kicad.override {
        stable = true;
      }
    );

    open-webui = inputs.open-webui-0-6-18.legacyPackages.${final.system}.open-webui;
  };
}
