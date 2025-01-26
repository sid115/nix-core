# wireplumber
{ lib, ... }:

let
  inherit (lib) mkDefault;
in
{
  format = mkDefault "{icon} {volume}";
  format-muted = mkDefault "mute"; # <U+f6a9> does not render. See issue #144
  format-icons = mkDefault [
    ""
    ""
    ""
  ];
  on-click = mkDefault "helvum";
  max-volume = mkDefault 150;
  scroll-step = mkDefault 1;
}
