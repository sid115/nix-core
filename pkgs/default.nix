{
  pkgs ? import <nixpkgs>,
  ...
}:

{
  baibot = pkgs.callPackage ./baibot { };
  blender-mcp = pkgs.callPackage ./blender-mcp { };
  cppman = pkgs.callPackage ./cppman { };
  marker-pdf = pkgs.callPackage ./marker-pdf { };
  mcpo = pkgs.callPackage ./mcpo { };
  pyman = pkgs.callPackage ./pyman { };
  synapse_change_display_name = pkgs.callPackage ./synapse_change_display_name { };
  visual-paradigm-community = pkgs.callPackage ./visual-paradigm-community { };
}
