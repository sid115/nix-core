{
  pkgs ? import <nixpkgs>,
  ...
}:

{
  chatbox = pkgs.callPackage ./chatbox { };
  cppman = pkgs.callPackage ./cppman { };
  # gitingest = pkgs.callPackage ./gitingest { }; # Hotfix for https://github.com/sid115/nix-core/issues/6
  google-genai = pkgs.callPackage ./google-genai { };
  marker-pdf = pkgs.callPackage ./marker-pdf { };
  pdftext = pkgs.callPackage ./pdftext { };
  pyman = pkgs.callPackage ./pyman { };
  surya-ocr = pkgs.callPackage ./surya-ocr { };
  synapse_change_display_name = pkgs.callPackage ./synapse_change_display_name { };

  pix2tex = pkgs.callPackage ./pix2tex { };

  # corryvreckan = pkgs.callPackage ./corryvreckan { }; # FIXME
  # plecs = pkgs.callPackage ./plecs { }; # FIXME
}
