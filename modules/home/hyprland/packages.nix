{ pkgs, ... }:

# use programs.PACKAGE or services.SERVICE when available

with pkgs;
[
  easyeffects
  file
  helvum
  libnotify
  python3Full
  udiskie
  udisks
  ventoy
  wev
  wl-clipboard

  # screen sharing for x11 apps
  grim
  slurp
  xwaylandvideobridge
]
