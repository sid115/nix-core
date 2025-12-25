{ config, lib, ... }:

let
  cfg = config.services.uptime-kuma;
  domain = config.networking.domain;
  subdomain = cfg.reverseProxy.subdomain;
  fqdn = if (cfg.reverseProxy.enable && subdomain != "") then "${subdomain}.${domain}" else domain;

  inherit (lib)
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in
{
  options.services.uptime-kuma = {
    reverseProxy = {
      enable = mkEnableOption "Nginx reverse proxy for uptime-kuma";
      subdomain = mkOption {
        type = types.str;
        default = "monitor";
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
    services.uptime-kuma = {
      settings = {
        HOST = mkDefault (if cfg.reverseProxy.enable then "127.0.0.1" else "0.0.0.0");
        PORT = mkDefault "3001";
      };
    };

    services.nginx.virtualHosts."${fqdn}" = mkIf cfg.reverseProxy.enable {
      forceSSL = cfg.reverseProxy.forceSSL;
      enableACME = cfg.reverseProxy.forceSSL;
      locations."/" = {
        proxyPass = mkDefault "http://127.0.0.1:${cfg.settings.PORT}";
      };
    };
  };
}
