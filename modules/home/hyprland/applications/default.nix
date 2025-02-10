{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.wayland.windowManager.hyprland;
  apps = cfg.applications;

  # dynamically create a set of default app assignments
  defaultApps = mapAttrs (name: app: app.default) apps;

  # function to generate the attribute set for each application
  mkAppAttrs =
    {
      default,
      bind ? [ "" ],
      windowRule ? [ "" ],
    }:
    {
      default = mkOption {
        type = types.str;
        default = default;
        description = "The default application to use for the ${default}.";
      };
      bind = mkOption {
        type = types.listOf types.str;
        default = bind;
        description = "The keybinding to use for the ${default}.";
      };
      windowrule = mkOption {
        type = types.listOf types.str;
        default = windowRule;
        description = "The window rule to use for the ${default}.";
      };
    };

  # generate lists of all binds and window rules and remove empty strings
  binds = filter (s: s != "") (
    builtins.concatLists (map (app: app.bind or [ "" ]) (attrValues apps))
  );
  windowrules = filter (s: s != "") (
    builtins.concatLists (map (app: app.windowrule or [ "" ]) (attrValues apps))
  );

  genAssociations =
    desktop: mimeTypes:
    builtins.listToAttrs (
      map (mimeType: {
        name = mimeType;
        value = desktop;
      }) mimeTypes
    );

  inherit (lib)
    attrValues
    filter
    mapAttrs
    mkOption
    types
    ;
in
{
  imports = [
    ./bemenu
    ./dmenu-bluetooth
    ./element-desktop
    ./feh
    ./kitty
    ./lf
    ./libreoffice
    ./librewolf
    ./mpv
    ./ncmpcpp
    ./networkmanager_dmenu
    ./newsboat
    ./passwordmanager
    ./powermenu-bemenu
    ./presentation-mode-bemenu
    ./qbittorrent
    ./screenshot
    ./thunderbird
    ./zathura
    # add your application directories here
  ];

  options.wayland.windowManager.hyprland.applications = with defaultApps; {
    applauncher = mkAppAttrs {
      default = "bemenu";
      bind = [ "$mod, d, exec, ${applauncher}-run" ];
    };

    audiomixer = mkAppAttrs {
      default = "pulsemixer";
      bind = [ "$mod, a, exec, ${terminal} -T ${audiomixer} -e ${pkgs.pulsemixer}/bin/pulsemixer" ];
      windowRule = [
        "float, title:^${audiomixer}$"
        "size 50% 50%, title:^${audiomixer}$"
      ];
    };

    bluetoothsettings = mkAppAttrs {
      default = "dmenu-bluetooth";
      bind = [ "$mod SHIFT, b, exec, ${bluetoothsettings}" ];
    };

    browser = mkAppAttrs {
      default = "librewolf";
      bind = [ "$mod, b, exec, ${browser}" ];
    };

    calculator = mkAppAttrs {
      default = "sage";
      bind = [
        ", XF86Calculator, exec, ${terminal} -T ${calculator} -e ${pkgs.sageWithDoc}/bin/sage"
      ];
    };

    emailclient = mkAppAttrs {
      default = "thunderbird";
      bind = [ "$mod, m, exec, ${emailclient}" ];
    };

    filemanager = mkAppAttrs {
      default = "lf";
      bind = [ "$mod, e, togglespecialworkspace, ${filemanager}" ]; # lf autostarts on this workspace
      windowRule = [
        "float, title:^${filemanager}$"
        "size 50% 50%, title:^${filemanager}$"
      ];
    };

    matrix-client = mkAppAttrs {
      default = "element-desktop";
      bind = [ "$mod SHIFT, e, exec, ${matrix-client}" ];
    };

    musicplayer = mkAppAttrs {
      default = "ncmpcpp";
      bind = [ "$mod SHIFT, m, exec, ${terminal} -T ${musicplayer} -e ${musicplayer}" ];
    };

    networksettings = mkAppAttrs {
      default = "networkmanager_dmenu";
      bind = [ "$mod SHIFT, n, exec, ${networksettings}" ];
    };

    office = mkAppAttrs {
      default = "libreoffice";
      bind = [ "$mod SHIFT, o, exec, ${office}" ];
    };

    password-manager = mkAppAttrs {
      default = "passwordmanager";
      bind = [ "$mod, p, exec, passmenu-bemenu" ];
    };

    imageviewer = mkAppAttrs { default = "feh"; };

    pdfviewer = mkAppAttrs { default = "zathura"; };

    powermenu = mkAppAttrs {
      default = "powermenu-bemenu";
      bind = [ "$mod SHIFT, q, exec, ${powermenu}" ];
    };

    presentation-mode = mkAppAttrs {
      default = "presentation-mode-bemenu";
      bind = [ "$mod SHIFT, p, exec, ${presentation-mode}" ];
    };

    rssreader = mkAppAttrs {
      default = "newsboat";
      bind = [ "$mod, n, exec, ${terminal} -T ${rssreader} -e ${rssreader}" ];
    };

    screenshotter = mkAppAttrs {
      default = "screenshot";
      bind = [
        "$mod,       Print, exec, ${screenshotter} output" # select monitor
        "$mod SHIFT, Print, exec, ${screenshotter} region" # select region
        "$mod CTRL,  Print, exec, ${screenshotter} window" # select window
      ];
    };

    terminal = mkAppAttrs {
      default = "kitty";
      bind = [ "$mod, Return, exec, ${terminal}" ];
    };

    torrent-client = mkAppAttrs { default = "qbittorrent"; };

    videoplayer = mkAppAttrs { default = "mpv"; };
  };

  config = {
    wayland.windowManager.hyprland.settings = {
      bind = binds;
      windowrulev2 = windowrules;
    };
  };
}
