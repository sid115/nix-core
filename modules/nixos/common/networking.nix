{ config, lib, ... }:

let
  isNotEmptyStr = str: builtins.isString str && str != "";

  inherit (lib) mkDefault;
in
{
  config = {
    assertions = [
      {
        assertion = isNotEmptyStr config.networking.domain;
        message = "nix-core/nixos/common: config.networking.domain cannot be empty.";
      }
      {
        assertion = isNotEmptyStr config.networking.hostName;
        message = "nix-core/nixos/common: config.networking.hostName cannot be empty.";
      }
    ];

    networking = {
      domain = mkDefault "${config.networking.hostName}.local";

      # NetworkManager
      useDHCP = false;
      wireless.enable = false;
      networkmanager.enable = true;
    };
  };
}
