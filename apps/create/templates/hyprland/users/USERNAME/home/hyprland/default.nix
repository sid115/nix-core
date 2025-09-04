{ inputs, ... }:

{
  imports = [
    inputs.core.homeModules.hyprland
    inputs.core.homeModules.stylix

    ./packages.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    autostart = true;
  };

  stylix.enable = true;
}
