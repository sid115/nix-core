{
  pkgs ? import <nixpkgs>,
  ...
}:

{
  baibot = pkgs.callPackage ./baibot { };
  cppman = pkgs.callPackage ./cppman { };
  gemini-cli = pkgs.callPackage ./gemini-cli { };
  pyman = pkgs.callPackage ./pyman { };
  synapse_change_display_name = pkgs.callPackage ./synapse_change_display_name { };
  visual-paradigm-community = pkgs.callPackage ./visual-paradigm-community { };
}
