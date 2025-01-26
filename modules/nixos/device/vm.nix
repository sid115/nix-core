{ lib, ... }:

let
  inherit (lib) mkDefault;
in
{
  services.qemuGuest.enable = mkDefault true;
  services.spice-vdagentd.enable = mkDefault true;
  services.spice-webdavd.enable = mkDefault true;
}
