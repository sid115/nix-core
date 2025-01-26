# pulseaudio input
{ lib, pkgs, ... }:

let
  helvum = "${pkgs.helvum}/bin/helvum";
  pactl = "${pkgs.pulseaudio}/bin/pactl";

  inherit (lib) mkDefault;
in
{
  format = mkDefault "{format_source}";
  format-source = mkDefault " {volume}";
  format-source-muted = mkDefault "";
  on-click = mkDefault "${pactl} set-source-mute 0 toggle";
  on-click-middle = mkDefault helvum;
  on-scroll-down = mkDefault "${pactl} set-source-volume 0 -5%";
  on-scroll-up = mkDefault "${pactl} set-source-volume 0 +5%";
  scroll-step = mkDefault 1;
  smooth-scrolling-threshold = mkDefault 1;
}
