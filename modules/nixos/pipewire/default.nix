{ lib, ... }:

let
  inherit (lib) mkDefault;
in
{
  services.pipewire = {
    wireplumber.enable = mkDefault true;
    alsa.enable = mkDefault true;
    pulse.enable = mkDefault true;
    jack.enable = mkDefault true;
    audio.enable = mkDefault true;
  };
}
