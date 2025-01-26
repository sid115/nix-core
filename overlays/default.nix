{ inputs, ... }:

{
  modifications = final: prev: {
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
