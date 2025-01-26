{ config, pkgs, ... }:

let
  newsboat = "${pkgs.newsboat}/bin/newsboat";
  notify = "${pkgs.libnotify}/bin/notify-send";
  signal = "${toString config.programs.waybar.settings.mainBar."custom/newsboat".signal}";
in
(pkgs.writeShellScriptBin "newsboat-reload" ''
  ${notify} -u low 'Newsboat' 'Reloading RSS feeds...' && ${newsboat} -x reload && ${notify} -u low 'Newsboat' 'RSS feeds reloaded.' && pkill -RTMIN+${signal} waybar
'')
