{
  pkgs ? import <nixpkgs>,
  ...
}:

{
  baibot = pkgs.callPackage ./baibot { };
  cppman = pkgs.callPackage ./cppman { };
  plecs = pkgs.callPackage ./plecs { };
  pyman = pkgs.callPackage ./pyman { };
  synapse_change_display_name = pkgs.callPackage ./synapse_change_display_name { };
}
