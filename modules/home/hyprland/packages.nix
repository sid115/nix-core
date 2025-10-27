{ pkgs, ... }:

# use `config.programs` or `config.services` when available

with pkgs;
[
  file
  grim
  helvum
  libnotify
  slurp
  udiskie
  udisks
  wev
  wl-clipboard
]
