{ config, lib, ... }:

let
  cfg = config.services.nginx;

  inherit (lib)
    mkDefault
    mkIf
    mkOption
    optional
    optionals
    types
    ;
in
{
  options.services.nginx = {
    forceSSL = mkOption {
      type = types.bool;
      default = false;
      description = "Force SSL for Nginx virtual host.";
    };
    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to open the firewall for HTTP (and HTTPS if forceSSL is enabled).";
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = optionals (
      [
        cfg.openFirewall
        80
      ]
      ++ optional cfg.forceSSL 443
    );

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
