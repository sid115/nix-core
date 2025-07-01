{ lib, ... }:

let
  inherit (lib) mkDefault;
in
{
  programs.zsh = {
    enable = mkDefault true;
    defaultKeymap = mkDefault "emacs";
    initContent =
      ''
        PROMPT='%F{green}%n%f@%F{blue}%m%f %B%1~%b > '
        RPROMPT='[%F{yellow}%?%f]'
      ''
      + builtins.readFile ./cdf.sh;
  };
}
