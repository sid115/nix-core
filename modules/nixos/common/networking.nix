{ config, lib, ... }:

let
  isNotEmpty = str: builtins.isString str && str != ""; # TODO: put in lib overlay
in
{
  config = {
    assertions = [
      {
        assertion = isNotEmpty config.networking.domain;
        message = "nix-core/nixos/common: config.networking.domain cannot be empty.";
      }
      {
        assertion = isNotEmpty config.networking.hostName;
        message = "nix-core/nixos/common: config.networking.hostName cannot be empty.";
      }
    ];

    networking = {
      domain = lib.mkDefault "${config.networking.hostName}.local";

      # NetworkManager
      useDHCP = false;
      wireless.enable = false;
      networkmanager.enable = true;
    };
  };
}
