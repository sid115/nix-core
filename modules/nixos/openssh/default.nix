{ lib, ... }:

let
  inherit (lib) mkDefault;
in
{
  services.openssh = {
    enable = mkDefault true;
    ports = mkDefault [ 2299 ];
    openFirewall = mkDefault true;
    settings = {
      PermitRootLogin = mkDefault "no";
      PasswordAuthentication = mkDefault false;
    };
  };
}
