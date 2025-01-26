{ lib, ... }:

let
  de = "de_DE.UTF-8";
  en = "en_US.UTF-8";

  inherit (lib) mkDefault;
in
{
  i18n = {
    defaultLocale = mkDefault en;
    extraLocaleSettings = {
      LC_ADDRESS = mkDefault de;
      LC_IDENTIFICATION = mkDefault de;
      LC_MEASUREMENT = mkDefault de;
      LC_MONETARY = mkDefault de;
      LC_NAME = mkDefault de;
      LC_NUMERIC = mkDefault de;
      LC_PAPER = mkDefault de;
      LC_TELEPHONE = mkDefault de;
      LC_TIME = mkDefault en;
    };
  };

  console = {
    font = mkDefault "Lat2-Terminus16";
    keyMap = mkDefault "de";
  };

  time.timeZone = mkDefault "Europe/Berlin";
}
