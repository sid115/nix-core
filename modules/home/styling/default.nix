{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.styling;
  schemesPath = ./schemes/${cfg.scheme};

  inherit (lib)
    mkDefault
    mkEnableOption
    mkForce
    mkIf
    mkOption
    types
    ;
in
{
  imports = [ inputs.stylix.homeManagerModules.stylix ];

  options.styling = {
    enable = mkEnableOption "Whether to enable styling via stylix.";
    scheme = mkOption {
      type = types.str;
      default = "dracula";
      description = ''
        Available color schemes are:
        "ayu" "dracula" "moonfly" "onedark" "oxocarbon" "tokyonight"
      '';
    };
    gaps = mkOption {
      type = types.int;
      default = 0;
      description = "Gaps in pixels for Waybar and Hyprland.";
    };
    radius = mkOption {
      type = types.int;
      default = 0;
      description = "Corner radius for widgets and windows in pixels for Waybar and Hyprland.";
    };
  };

  config = mkIf cfg.enable {
    stylix = {
      enable = true;
      autoEnable = true;
      targets = {
        # stylix sucks with these:
        bemenu.enable = false;
        kde.enable = false;
        waybar.enable = false;

        # disable stylix if nixvim has the corresponding color scheme implemented itself
        nixvim.enable = mkIf (
          cfg.scheme == "ayu"
          || cfg.scheme == "dracula"
          || cfg.scheme == "onedark"
          || cfg.scheme == "oxocarbon"
          || cfg.scheme == "tokyonight"
        ) false;
      };
      base16Scheme = schemesPath + "/colors.yaml"; # TODO: look into ${pkgs.base16-schemes}/share/themes/THEME.yaml
      fonts = {
        monospace = mkDefault {
          package = pkgs.hack-font;
          name = "Hack";
        };
      };
      image = schemesPath + "/wallpaper.png";
      polarity = "dark";
    };

    # handle styling manually
    programs.waybar = {
      style = import ./custom/waybar/style.nix { inherit config; };
      settings = import ./custom/waybar/settings.nix { inherit config; };
    };
    programs.bemenu = {
      settings = import ./custom/bemenu/settings.nix { inherit config; };
    };
    wayland.windowManager.hyprland = {
      settings = import ./custom/hyprland/settings.nix { inherit config lib; };
    };

    # set nixvim color scheme if it has the scheme implemented
    programs.nixvim.colorschemes = {
      ayu.enable = mkIf (cfg.scheme == "ayu") (mkForce true);
      dracula.enable = mkIf (cfg.scheme == "dracula") (mkForce true);
      onedark.enable = mkIf (cfg.scheme == "onedark") (mkForce true);
      oxocarbon.enable = mkIf (cfg.scheme == "oxocarbon") (mkForce true);
      tokyonight.enable = mkIf (cfg.scheme == "tokyonight") (mkForce true);
    };
  };
}
