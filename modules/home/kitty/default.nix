{ lib, ... }:

let
  inherit (lib) mkDefault;
in
{
  programs.kitty = {
    settings = {
      confirm_os_window_close = mkDefault 0;
      enable_audio_bell = mkDefault "no";
      window_margin_width = mkDefault 5;
    };
  };

  home.sessionVariables = {
    TERMINAL = "kitty";
  };

  home.shellAliases = {
    ssh = "kitten ssh"; # copy terminfo
  };
}
