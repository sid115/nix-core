{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.wayland.windowManager.hyprland;
  app = cfg.applications.emailclient.default;
  desktop = "thunderbird.desktop";
  mimeTypes = [
    "message/rfc822"
    "x-scheme-handler/mailto"
    "text/calendar"
    "text/x-vcard"
  ];
  associations =
    let
      genMimeAssociations = import ../genMimeAssociations.nix;
    in
    genMimeAssociations desktop mimeTypes;

  inherit (lib) mkIf;
in
{
  config = mkIf (cfg.enable && app == "thunderbird") {
    home.packages = [ pkgs.thunderbird ];

    # programs.thunderbird = {
    #   enable = true;
    #   profiles.default = {
    #     isDefault = mkDefault true;
    #     withExternalGnupg = mkDefault true;
    #   };
    # };

    xdg.mimeApps = {
      defaultApplications = associations;
      associations.added = associations;
    };
  };
}
