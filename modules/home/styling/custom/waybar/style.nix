{ config, ... }:

let
  cfg = config.styling;
  colors = config.lib.stylix.colors.withHashtag;
  gaps = toString (4 + cfg.gaps);
  halfgaps = toString (2 + cfg.gaps / 2);
  radius = toString cfg.radius;
in
''
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
''
