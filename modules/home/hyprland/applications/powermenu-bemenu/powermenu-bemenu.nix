{ config, pkgs, ... }:

(pkgs.writeShellScriptBin "powermenu-bemenu" ''
  case $(echo -e "shutdown\nreboot\nlock\nkill" | bemenu -p "") in
  	shutdown) systemctl poweroff ;;
  	reboot) systemctl reboot ;;
    lock) "${config.programs.hyprlock.package}/bin/hyprlock" ;;
  	kill) hyprctl dispatch exit ;;
  esac
'')
