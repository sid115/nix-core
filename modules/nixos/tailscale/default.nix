{ config, lib, ... }:

let
  cfg = config.services.tailscale;

  inherit (lib)
    mkIf
    mkOption
    optional
    types
    ;
in
{
  options.services.tailscale = {
    loginServer = mkOption {
      type = types.str;
      description = "The Tailscale login server to use.";
    };
    enableSSH = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Tailscale SSH functionality.";
    };
  };

  config = mkIf cfg.enable {
    services.tailscale = {
      authKeyFile = config.sops.secrets."tailscale/auth-key".path;
      extraSetFlags = optional cfg.enableSSH "--ssh";
      extraUpFlags = [
        "--login-server=${cfg.loginServer}"
      ]
      ++ optional cfg.enableSSH "--ssh";
    };

    environment.shellAliases = {
      ts = "${cfg.package}/bin/tailscale";
    };

    networking.firewall.trustedInterfaces = [ cfg.interfaceName ];

    sops.secrets."tailscale/auth-key" = { };
  };
}
