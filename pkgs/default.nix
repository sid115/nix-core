{
  pkgs ? import <nixpkgs>,
  ...
}:

{
  baibot = pkgs.callPackage ./baibot { };
  cppman = pkgs.callPackage ./cppman { };
  marker-pdf = pkgs.callPackage ./marker.pdf { };
  pyman = pkgs.callPackage ./pyman { };
  synapse_change_display_name = pkgs.callPackage ./synapse_change_display_name { };
}
