{ outputs, ... }:

{
  nixpkgs.overlays = [
    outputs.overlays.core-packages
    outputs.overlays.local-packages
    outputs.overlays.modifications
    outputs.overlays.old-stable-packages
    outputs.overlays.unstable-packages
  ];
}
