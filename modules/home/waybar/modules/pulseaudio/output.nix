# pulseaudio output
{ lib, pkgs, ... }:

let
  helvum = "${pkgs.helvum}/bin/helvum";
  pactl = "${pkgs.pulseaudio}/bin/pactl";

  inherit (lib) mkDefault;
in
{
  format = mkDefault "{icon} {volume}";
  format-muted = mkDefault "x";
  format-icons = mkDefault {
    default = mkDefault [
      ""
      ""
      ""
    ];
  };
  max-volume = mkDefault 150;
  on-click = mkDefault "${pactl} set-sink-mute 0 toggle";
  on-click-middle = mkDefault helvum;
  on-scroll-down = mkDefault "${pactl} set-sink-volume 0 -5%";
  on-scroll-up = mkDefault "${pactl} set-sink-volume 0 +5%";
  scroll-step = mkDefault 5;
  smooth-scrolling-threshold = mkDefault 1;
}
