{ inputs, pkgs, ... }:

with inputs.nur.legacyPackages."${pkgs.system}".repos.rycee.firefox-addons;

[
  darkreader
  floccus
  ublock-origin
]
