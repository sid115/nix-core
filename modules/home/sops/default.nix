{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

let
  secrets = "${toString inputs.self}/users/${config.home.username}/home/secrets/secrets.yaml";
in
{
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  home.packages = with pkgs; [
    age
    sops
  ];

  sops.defaultSopsFile = lib.mkIf (builtins.pathExists secrets) (lib.mkDefault secrets);
  sops.age.keyFile = lib.mkDefault "${config.home.homeDirectory}/.config/sops/age/keys.txt";
}
