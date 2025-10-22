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
      postPatch = ''
        substituteInPlace pyproject.toml \
          --replace-fail "setuptools_rust>=1.3,<=1.11.1" "setuptools_rust<=1.12,>=1.3" \
          --replace-fail "poetry-core>=1.1.0,<=2.1.3" "poetry-core>=1.1.0,<=2.3.0"
      '';
    });

    open-webui = inputs.open-webui-0-6-18.legacyPackages.${final.system}.open-webui;
  };
}
