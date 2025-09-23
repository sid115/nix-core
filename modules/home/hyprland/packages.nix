{ pkgs, ... }:

# use programs.PACKAGE or services.SERVICE when available

with pkgs;
[
  file
  helvum
  libnotify
  udiskie
  udisks
  # ventoy # https://github.com/NixOS/nixpkgs/issues/404663
  wev
  wl-clipboard

  # screen sharing for x11 apps
  grim
  slurp
  kdePackages.xwaylandvideobridge
]
