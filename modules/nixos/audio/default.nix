{ pkgs, lib, ... }:

let
  inherit (lib) mkDefault;
in
{
  services.pipewire = {
    enable = mkDefault true;
    wireplumber.enable = mkDefault true;
    alsa.enable = mkDefault true;
    pulse.enable = mkDefault true;
    jack.enable = mkDefault true;
    audio.enable = mkDefault true;
  };

  services.pulseaudio.enable = false;

  security.rtkit.enable = mkDefault true;

  environment.systemPackages = with pkgs; [
    pulseaudioFull
  ];
}
