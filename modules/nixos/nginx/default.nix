{ config, lib, ... }:

let
  cfg = config.services.nginx;

  inherit (lib)
    mkDefault
    mkIf
    mkOption
    types
    ;
in
{
  options.services.nginx = {
    forceSSL = mkOption {
      type = types.bool;
      default = true;
      description = "Force SSL for Nginx virtual host.";
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [
      80 # ACME challenge
      443
    ];

    services.nginx = {
      enable = mkDefault true;
      recommendedOptimisation = mkDefault true;
      recommendedGzipSettings = mkDefault true;
      recommendedProxySettings = mkDefault true;
      recommendedTlsSettings = cfg.forceSSL;
      virtualHosts = {
        "${config.networking.domain}" = {
          enableACME = cfg.forceSSL;
          forceSSL = cfg.forceSSL;
        };
      };
    };

    security.acme = mkIf cfg.forceSSL {
      acceptTerms = true;
      defaults.email = "postmaster@${config.networking.domain}";
      defaults.webroot = "/var/lib/acme/acme-challenge";
      certs."${config.networking.domain}".postRun = "systemctl reload nginx.service";
    };
  };
}
