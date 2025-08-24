{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

let
  secrets = "${toString inputs.self}/hosts/${config.networking.hostName}/secrets/secrets.yaml";
in
{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  environment.systemPackages = with pkgs; [
    age
    sops
  ];

  sops.defaultSopsFile = lib.mkIf (builtins.pathExists secrets) (lib.mkDefault secrets);
}
