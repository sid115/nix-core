{
  pkgs ? import <nixpkgs>,
  ...
}:

{
  baibot = pkgs.callPackage ./baibot { };
  cppman = pkgs.callPackage ./cppman { };
  neorv32-gnu-toolchain = pkgs.callPackage ./neorv32-gnu-toolchain { };
  pyman = pkgs.callPackage ./pyman { };
  synapse_change_display_name = pkgs.callPackage ./synapse_change_display_name { };
  visual-paradigm-community = pkgs.callPackage ./visual-paradigm-community { };
}
