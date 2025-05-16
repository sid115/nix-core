{ inputs, ... }:

{
  imports = [
    inputs.core.homeModules.hyprland
    inputs.core.homeModules.styling

    ./packages.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    autostart = true;
  };

  styling.enable = true;
}
