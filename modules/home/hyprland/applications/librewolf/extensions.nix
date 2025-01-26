{ inputs, pkgs, ... }:

with inputs.nur.legacyPackages."${pkgs.system}".repos.rycee.firefox-addons;

# ublock-origin already comes with librewolf by default
[
  darkreader
  floccus
  sidebery
]
