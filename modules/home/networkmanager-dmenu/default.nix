{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.networkmanager-dmenu;

  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in
{
  options.programs.networkmanager-dmenu = {
    enable = mkEnableOption "Whether to enable networkmanager-dmenu.";

    package = mkOption {
      type = types.package;
      default = pkgs.networkmanager_dmenu;
      description = "The package to use for networkmanager-dmenu.";
    };

    config = {
      dmenu = {
        dmenu_command = mkOption {
          type = types.str;
          default = "dmenu";
          description = "Command for dmenu, can include arguments.";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      cfg.package
      pkgs.modemmanager # for "Enable WWAN"
      pkgs.networkmanager # for `nmcli`
      pkgs.networkmanagerapplet # for "Launch Connection Manager"

      pkgs.networkmanager-openconnect # VPN support
      pkgs.openconnect # VPN support
    ];

    xdg.configFile."networkmanager-dmenu/config.ini".text = ''
      [dmenu]
      dmenu_command=${cfg.config.dmenu.dmenu_command}
    '';
  };
}
