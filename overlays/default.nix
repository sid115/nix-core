{ inputs, ... }:

{
  # lib = final: prev: { lib = prev.lib // import ../lib; }; # FIXME

  modifications = final: prev: {
    comfyui = inputs.nixpkgs-comfyui.legacyPackages.${final.system}.comfyui;

    # for open-webui since onnxruntime fails to build 
    # https://github.com/NixOS/nixpkgs/issues/388681#issuecomment-2778618490
    pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
      (python-final: python-prev: {
        onnxruntime = python-prev.onnxruntime.overridePythonAttrs (oldAttrs: {
          buildInputs = final.lib.lists.remove final.onnxruntime oldAttrs.buildInputs;
        });
      })
    ];

    # https://github.com/NixOS/nixpkgs/issues/335003#issuecomment-2755803376
    kicad = (
      prev.kicad.override {
        stable = true;
      }
    );

    # You should use the Flatpak instead.
    zoom-us =
      let
        # see: https://github.com/NixOS/nixpkgs/issues/322970
        version = "6.0.2.4680";
        # pipewire v1.0.7
        pipewire = inputs.nixpkgs-zoom.legacyPackages.${final.system}.pipewire;
      in
      (prev.zoom-us.override { inherit pipewire; }).overrideAttrs (old: {
        inherit version;
        src = final.fetchurl {
          url = "https://zoom.us/client/${version}/zoom_x86_64.pkg.tar.xz";
          hash = "sha256-027oAblhH8EJWRXKIEs9upNvjsSFkA0wxK1t8m8nwj8=";
        };
      });
  };
}
