{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.gpg;

  inherit (lib) mkDefault mkIf;
in
{
  programs.gpg = {
    enable = mkDefault true;
  };
  services.gpg-agent = mkIf cfg.enable {
    defaultCacheTtl = mkDefault 600;
    defaultCacheTtlSsh = mkDefault 600;
    enable = mkDefault true;
    enableScDaemon = mkDefault false;
    enableSshSupport = mkDefault true;
    maxCacheTtl = mkDefault 7200;
    maxCacheTtlSsh = mkDefault 7200;
    pinentry.package = mkDefault pkgs.pinentry-qt;
    verbose = mkDefault true;
  };
  programs.ssh = {
    enable = mkDefault true;
  };
  # FIXME: couldn't access control socket
  services.gnome-keyring = {
    enable = mkDefault true;
    components = [ "secrets" ];
  };
}
