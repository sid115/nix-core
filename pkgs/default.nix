{
  pkgs ? import <nixpkgs>,
  ...
}:

{
  chatbox = pkgs.callPackage ./chatbox { };
  gitingest = pkgs.callPackage ./gitingest { };
  corryvreckan = pkgs.callPackage ./corryvreckan { };
  cppman = pkgs.callPackage ./cppman { };
  pyman = pkgs.callPackage ./pyman { };
  synapse_change_display_name = pkgs.callPackage ./synapse_change_display_name { };

  # plecs = pkgs.callPackage ./plecs { }; # FIXME
}
