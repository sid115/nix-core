{ lib, ... }:

let
  inherit (lib) mkDefault;
in
{
  programs.bemenu = {
    settings = {
      border = mkDefault 2;
      border-radius = mkDefault 10;
      center = mkDefault true;
      ignorecase = mkDefault true;
      list = mkDefault "20 down";
      margin = mkDefault 5;
      prompt = mkDefault "";
      scrollbar = mkDefault "none";
      width-factor = mkDefault 0.3;
      wrap = mkDefault true;
    };
  };
}
