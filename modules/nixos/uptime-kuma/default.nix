{ config, lib, ... }:

let
  cfg = config.services.uptime-kuma;
  domain = config.networking.domain;
  subdomain = cfg.reverseProxy.subdomain;
  fqdn = if (cfg.reverseProxy.enable && subdomain != "") then "${subdomain}.${domain}" else domain;

  inherit (lib)
    mkDefault
    mkIf
    ;

  inherit (lib.utils)
    mkReverseProxyOption
    mkVirtualHost
    ;
in
{
  options.services.uptime-kuma = {
    reverseProxy = mkReverseProxyOption "Uptime Kuma" "monitor";
  };

  config = mkIf cfg.enable {
    services.uptime-kuma = {
      settings = {
        HOST = mkDefault (if cfg.reverseProxy.enable then "127.0.0.1" else "0.0.0.0");
        PORT = mkDefault "3001";
      };
    };

    services.nginx.virtualHosts = mkIf cfg.reverseProxy.enable {
      "${fqdn}" = mkVirtualHost {
        inherit config fqdn;
        port = cfg.settings.PORT;
        ssl = cfg.reverseProxy.forceSSL;
      };
    };
  };
}
