{
  pkgs ? import <nixpkgs>,
  ...
}:

{
  baibot = pkgs.callPackage ./baibot { };
  chatbox = pkgs.callPackage ./chatbox { };
  corryvreckan = pkgs.callPackage ./corryvreckan { };
  cppman = pkgs.callPackage ./cppman { };
  gitingest = pkgs.callPackage ./gitingest { };
  pyman = pkgs.callPackage ./pyman { };
  synapse_change_display_name = pkgs.callPackage ./synapse_change_display_name { };

  # plecs = pkgs.callPackage ./plecs { }; # FIXME
}
