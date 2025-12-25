{ config, lib, ... }:

let
  cfg = config.services.nginx;

  inherit (lib)
    mkDefault
    mkIf
    mkOption
    optional
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
      80
    ]
    ++ optional cfg.forceSSL 443;

    services.nginx = {
      recommendedOptimisation = mkDefault true;
      recommendedGzipSettings = mkDefault true;
      recommendedProxySettings = mkDefault true;
      recommendedTlsSettings = cfg.forceSSL;
      virtualHosts = {
        "${config.networking.domain}" = mkDefault {
          enableACME = cfg.forceSSL;
          forceSSL = cfg.forceSSL;
        };
      };
    };

    security.acme = mkIf cfg.forceSSL {
      acceptTerms = true;
      defaults.email = mkDefault "postmaster@${config.networking.domain}";
      defaults.webroot = mkDefault "/var/lib/acme/acme-challenge";
      certs."${config.networking.domain}".postRun = "systemctl reload nginx.service";
    };
  };
}
