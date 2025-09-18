{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.virtualisation.quickemu;

  inherit (lib) mkEnableOption mkIf;
in
{
  options.virtualisation.quickemu = {
    enable = mkEnableOption "Whether to enable quickemu.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      quickemu
    ];

    boot.extraModprobeConfig = ''
      options kvm_amd nested=1
      options kvm ignore_msrs=1 report_ignored_msrs=0
    '';
  };
}
