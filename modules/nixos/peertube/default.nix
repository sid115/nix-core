{ config, lib, ... }:

let
  cfg = config.services.peertube;
  domain = config.networking.domain;
  subdomain = cfg.reverseProxy.subdomain;
  fqdn = if (subdomain != "") then "${subdomain}.${domain}" else domain;

  inherit (lib)
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in
{
  options.services.peertube = {
    reverseProxy = {
      enable = mkEnableOption "Nginx reverse proxy for PeerTube";
      subdomain = mkOption {
        type = types.str;
        default = "vid";
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
    services.peertube = {
      localDomain = fqdn;
      enableWebHttps = cfg.reverseProxy.forceSSL;
      listenLocal = mkDefault false;
      configureNginx = mkDefault true;
      secrets.secretsFile = mkDefault config.sops.secrets."peertube/secret".path;
      database.createLocally = mkDefault true;
      redis.createLocally = mkDefault true;
      settings = {
        signup = {
          enabled = mkDefault false;
          requires_approval = mkDefault true;
        };
      };
    };

    security.acme.certs."${fqdn}".postRun = mkIf (
      with cfg.reverseProxy; enable && forceSSL
    ) "systemctl restart peertube.service";

    services.nginx.virtualHosts."${fqdn}" = mkIf cfg.reverseProxy.enable {
      enableACME = cfg.reverseProxy.forceSSL;
      forceSSL = cfg.reverseProxy.forceSSL;
      locations."/".proxyPass = mkDefault "http://127.0.0.1:${toString cfg.listenWeb}";
    };

    sops.secrets."peertube/secret" = {
      owner = "peertube";
      group = "peertube";
      mode = "0440";
    };
  };
}
