{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.xrdp;

  inherit (lib)
    mkDefault
    mkIf
    mkOption
    types
    ;
in
{
  imports = [
    ./plasma.nix
    ./xfce.nix
  ];

  options.services.xrdp = {
    desktop = mkOption {
      type = types.str;
      default = "none";
      description = ''
        Default desktop environment to use. Available options are:
        "xfce" "plasma" "none"
        When using "none", you have to set up a display and window manager manually.
      '';
    };
  };

  config = {
    services.xrdp = {
      openFirewall = mkDefault true;
      defaultWindowManager = mkIf (cfg.desktop == "none") "";
    };

    services.xserver = {
      enable = mkDefault true;
      xkb.layout = mkDefault "de";
      displayManager.startx.enable = mkDefault true;
    };
    services.libinput.enable = mkDefault true;
    services.xserver.desktopManager.xterm.enable = mkDefault false;
    hardware.opengl.enable = mkDefault true;
    hardware.opengl.driSupport = mkDefault true;

    environment.systemPackages = with pkgs; [
      xorg.xorgserver
      xorg.xf86inputevdev
      xorg.xf86inputsynaptics
      xorg.xf86inputlibinput
      xorg.xf86videointel
      xorg.xf86videoati
      xorg.xf86videonouveau
      xorg.xinit
      xclip
      dbus
    ];
  };
}
