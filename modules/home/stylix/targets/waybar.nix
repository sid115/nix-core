{ config, lib, ... }:

let
  cfg = config.stylix;
  target = cfg.targets.waybar';

  colors = config.lib.stylix.colors.withHashtag;
  gaps = toString (4 + target.gaps);
  halfgaps = toString (2 + target.gaps / 2);
  radius = toString target.radius;

  bar = {
    margin = "0 ${gaps} 0 ${gaps}";
    tray = {
      spacing = target.gaps;
    };

    # calendar has no css
    clock.calendar.format = {
      months = "<span color='${colors.blue}'><b>{}</b></span>";
      weeks = "<span color='${colors.magenta}'><b>W{}</b></span>";
      weekdays = "<span color='${colors.green}'><b>{}</b></span>";
      today = "<span color='${colors.red}'><b><u>{}</u></b></span>";
    };
  };

  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in
{
  options.stylix.targets.waybar' = {
    enable = mkEnableOption "Enable waybar' target for Stylix.";
    gaps = mkOption {
      type = types.int;
      default = cfg.targets.hyprland.gaps;
      description = "Widget gaps in pixels.";
    };
    radius = mkOption {
      type = types.int;
      default = cfg.targets.hyprland.radius;
      description = "Widget corner radius in pixels.";
    };
  };

  config = mkIf (cfg.enable && target.enable) {
    stylix.targets.waybar.enable = false;

    programs.waybar = {
      settings = {
        mainBar = bar;
        otherBar = bar;
      };

      style = ''
        * {
          border-radius: ${radius}px;
          border: none;
          font-family: monospace;
          font-size: 15px;
          min-height: 5px;
          transition: none;
        }

        window#waybar {
          background: transparent;
        }

         #workspaces {
          color: ${colors.base05};
          background: ${colors.base00};
        }

        #workspaces button {
          padding: ${halfgaps}px;
        }

        #workspaces button.active {
          color: ${colors.blue};
        }

        #workspaces button.urgent {
          color: ${colors.orange};
        }

        #workspaces button:hover {
          color: ${colors.base00};
          background: ${colors.base02};
        }

        #clock {
          padding: ${gaps}px;
        }

        #cpu, #memory, #network, #battery, #keyboard-state, #disk, #bluetooth, #wireplumber, #pulseaudio, #language, #custom-newsboat, #custom-timer, #tray {
          margin-left: ${gaps}px;
          padding: ${gaps}px;
        }

        #keyboard-state label.locked {
          background-color: ${colors.base00};
          color: ${colors.blue};
        }

        #battery.charging {
          background-color: ${colors.green};
          color: ${colors.base00};
        }

        #battery.warning:not(.charging) {
          background-color: ${colors.yellow};
          color: ${colors.base00};
        }

        #battery.critical:not(.charging) {
          background-color: ${colors.red};
          color: ${colors.base00};
        }

        #bluetooth.discovering {
          background-color: ${colors.blue};
          color: ${colors.base00};
        }
      '';
    };
  };
}
