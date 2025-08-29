{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.wayland.windowManager.hyprland;

  inherit (lib)
    mkDefault
    mkOption
    mkIf
    types
    ;
in
{
  imports = [
    ../waybar

    ./applications
    ./binds
    # ./chromium.nix # FIXME: Chromium crashes system on launch
    ./cursor.nix
    ./hyprlock.nix
    ./xdg
  ];

  options.wayland.windowManager.hyprland = {
    autostart = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to automatically start Hyprland after login.";
    };
    modifier = mkOption {
      type = types.str;
      default = "SUPER";
      description = "The modifier key to use.";
    };
  };

  config = {
    wayland.windowManager.hyprland = {
      systemd = {
        enable = mkDefault true;
        enableXdgAutostart = mkDefault false;
        variables = mkDefault [ "--all" ];
        # extraCommands = [ # fix for dunst
        #   "${pkgs.dbus}/bin/dbus-update-activation-environment WAYLAND_DISPLAY"
        #   "systemctl --user restart dunst.service"
        # ];
      };
      xwayland.enable = mkDefault true;
      settings = import ./settings.nix { inherit config lib pkgs; };
    };

    # Set some environment variables that hopefully fix some Wayland stuff
    home.sessionVariables = {
      CLUTTER_BACKEND = mkDefault "wayland";
      GDK_BACKEND = mkDefault "wayland";
      MOZ_ENABLE_WAYLAND = mkDefault 1;
      NIXOS_OZONE_WL = mkDefault 1;
      QT_AUTO_SCREEN_SCALE_FACTOR = mkDefault 1;
      QT_QPA_PLATFORM = mkDefault "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = mkDefault 1;
      WAYLAND_DISPLAY = mkDefault "wayland-1";
      XDG_CURRENT_DESKTOP = mkDefault "Hyprland";
      XDG_SESSION_DESKTOP = mkDefault "Hyprland";
      XDG_SESSION_TYPE = mkDefault "wayland";

      # WLR_RENDERER_ALLOW_SOFTWARE = mkDefault 1; # TODO: For VMs only?
    };

    # waybar
    programs.waybar.enable = mkIf cfg.enable (mkDefault true);

    # auto discover fonts in `home.packages`
    fonts.fontconfig.enable = true;

    # notifications
    services.dunst = {
      enable = mkDefault true;
      waylandDisplay = config.home.sessionVariables.WAYLAND_DISPLAY;
    };

    # install some applications
    home.packages = import ./packages.nix { inherit pkgs; }; # use programs.PACKAGE or services.SERVICE when possible

    # autostart
    home.file.hyprland-autostart = mkIf cfg.autostart {
      source = ./scripts/autostart;
      target = if config.programs.zsh.enable then ".zlogin" else ".profile";
    };

    services.udiskie = {
      enable = mkDefault true;
      tray = mkDefault "never";
    };
  };
}
