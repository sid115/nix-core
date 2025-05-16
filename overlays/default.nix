{ inputs, ... }:

{
  lib = final: prev: prev.lib // import ../lib;

  modifications = final: prev: {
    comfyui = inputs.nixpkgs-comfyui.legacyPackages.${final.system}.comfyui;

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
