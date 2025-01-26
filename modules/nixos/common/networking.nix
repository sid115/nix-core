{ config, lib, ... }:

{
  config.networking = {
    domain = lib.mkDefault "${config.networking.hostName}.local";

    # NetworkManager
    useDHCP = false;
    wireless.enable = false;
    networkmanager.enable = true;
  };
}
