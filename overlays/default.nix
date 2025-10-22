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

    # ERROR Missing dependencies: poetry-core<=2.1.3,>=1.1.0
    matrix-synapse = prev.matrix-synapse.overrideAttrs (oldAttrs: {
      pythonRemoveDeps = (oldAttrs.pythonRemoveDeps or [ ]) ++ [ "poetry-core" ];
    });

    open-webui = inputs.open-webui-0-6-18.legacyPackages.${final.system}.open-webui;
  };
}
