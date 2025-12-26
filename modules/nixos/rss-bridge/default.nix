{ config, lib, ... }:

let
  cfg = config.services.rss-bridge;
  domain = config.networking.domain;
  subdomain = cfg.reverseProxy.subdomain;
  fqdn = if (cfg.reverseProxy.enable && subdomain != "") then "${subdomain}.${domain}" else domain;

  inherit (lib)
    mkIf
    ;

  inherit (lib.utils)
    mkReverseProxyOption
    mkVirtualHost
    ;
in
{
  options.services.rss-bridge = {
    reverseProxy = mkReverseProxyOption "RSS-Bridge" "rss";
  };

  config = mkIf cfg.enable {
    services.rss-bridge = {
      virtualHost = fqdn;
      config = {
        system.enabled_bridges = [ "*" ];
      };
    };

    systemd.tmpfiles.rules = [ "d ${cfg.dataDir} 0755 ${cfg.user} ${cfg.group} -" ];

    services.nginx.virtualHosts = mkIf cfg.reverseProxy.enable {
      "${fqdn}" = mkVirtualHost {
        inherit config fqdn;
        ssl = cfg.reverseProxy.forceSSL;
      };
    };
  };
}
