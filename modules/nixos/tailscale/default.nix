{ config, lib, ... }:

let
  cfg = config.services.tailscale;

  inherit (lib) mkIf mkOption types;
in
{
  options.services.tailscale = {
    loginServer = mkOption {
      type = types.str;
      description = "The Tailscale login server to use.";
    };
  };

  config = mkIf cfg.enable {
    environment.shellAliases = {
      ts = "${cfg.package}/bin/tailscale";
    };

    services.tailscale = {
      authKeyFile = config.sops.secrets."tailscale/auth-key".path;
      extraUpFlags = [
        "--login-server=${cfg.loginServer}"
        "--ssh"
      ];
    };

    sops.secrets."tailscale/auth-key" = { };
  };
}
