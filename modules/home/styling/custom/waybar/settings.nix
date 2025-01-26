{ config, ... }:

let
  cfg = config.styling;
  gaps = toString (4 + cfg.gaps);
  colors = config.lib.stylix.colors.withHashtag;
in
rec {
  mainBar = {
    margin = "0 ${gaps} 0 ${gaps}";
    tray = {
      spacing = cfg.gaps;
    };

    # calendar has no css
    clock.calendar.format = {
      months = "<span color='${colors.blue}'><b>{}</b></span>";
      weeks = "<span color='${colors.magenta}'><b>W{}</b></span>";
      weekdays = "<span color='${colors.green}'><b>{}</b></span>";
      today = "<span color='${colors.red}'><b><u>{}</u></b></span>";
    };
  };

  otherBar = mainBar;
}
