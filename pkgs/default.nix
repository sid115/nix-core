{
  pkgs ? import <nixpkgs>,
  ...
}:

{
  chatbox = pkgs.callPackage ./chatbox { };
  corryvreckan = pkgs.callPackage ./corryvreckan { };
  cppman = pkgs.callPackage ./cppman { };
  fastapi-analytics = pkgs.callPackage ./fastapi-analytics { };
  gitingest = pkgs.callPackage ./gitingest { };
  google-genai = pkgs.callPackage ./google-genai { };
  marker-pdf = pkgs.callPackage ./marker-pdf { };
  pdftext = pkgs.callPackage ./pdftext { };
  pyman = pkgs.callPackage ./pyman { };
  surya-ocr = pkgs.callPackage ./surya-ocr { };
  synapse_change_display_name = pkgs.callPackage ./synapse_change_display_name { };

  # plecs = pkgs.callPackage ./plecs { }; # FIXME
}
