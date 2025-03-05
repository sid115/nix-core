{
  pkgs ? import <nixpkgs>,
  ...
}:

{
  baibot = pkgs.callPackage ./baibot { };
  chatbox = pkgs.callPackage ./chatbox { };
  cppman = pkgs.callPackage ./cppman { };
  gitingest = pkgs.callPackage ./gitingest { };
  google-genai = pkgs.callPackage ./google-genai { };
  marker-pdf = pkgs.callPackage ./marker-pdf { };
  pdftext = pkgs.callPackage ./pdftext { };
  pyman = pkgs.callPackage ./pyman { };
  surya-ocr = pkgs.callPackage ./surya-ocr { };
  synapse_change_display_name = pkgs.callPackage ./synapse_change_display_name { };

  # corryvreckan = pkgs.callPackage ./corryvreckan { }; # FIXME
  # plecs = pkgs.callPackage ./plecs { }; # FIXME
}
