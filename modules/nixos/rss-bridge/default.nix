{ config, lib, ... }:

let
  cfg = config.services.rss-bridge;
  domain = config.networking.domain;
  subdomain = cfg.reverseProxy.subdomain;
  fqdn = if (cfg.reverseProxy.enable && subdomain != "") then "${subdomain}.${domain}" else domain;

  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in
{
  options.services.rss-bridge = {
    reverseProxy = {
      enable = mkEnableOption "Nginx reverse proxy for RSS-Bridge.";
      subdomain = mkOption {
        type = types.str;
        default = "rss";
        description = "Subdomain for Nginx virtual host. Leave empty for root domain.";
      };
      forceSSL = mkOption {
        type = types.bool;
        default = true;
        description = "Force SSL for Nginx virtual host.";
      };
    };
  };

  config = mkIf cfg.enable {
    services.rss-bridge = {
      virtualHost = fqdn;
      config = {
        system.enabled_bridges = [ "*" ];
      };
    };

    systemd.tmpfiles.rules = [ "d ${cfg.dataDir} 0755 ${cfg.user} ${cfg.group} -" ];

    services.nginx.virtualHosts."${fqdn}" = mkIf cfg.reverseProxy.enable {
      forceSSL = cfg.reverseProxy.forceSSL;
      enableACME = cfg.reverseProxy.forceSSL;
      sslCertificate = mkIf cfg.reverseProxy.forceSSL "${
        config.security.acme.certs."${fqdn}".directory
      }/cert.pem";
      sslCertificateKey = mkIf cfg.reverseProxy.forceSSL "${
        config.security.acme.certs."${fqdn}".directory
      }/key.pem";
    };
  };
}
