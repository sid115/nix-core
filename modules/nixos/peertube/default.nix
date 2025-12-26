{ config, lib, ... }:

let
  cfg = config.services.peertube;
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
  options.services.peertube = {
    reverseProxy = mkReverseProxyOption "PeerTube" "vid";
  };

  config = mkIf cfg.enable {
    services.peertube = {
      localDomain = fqdn;
      enableWebHttps = mkDefault (with cfg.reverseProxy; enable && forceSSL);
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

    security.acme.certs = mkIf (with cfg.reverseProxy; enable && forceSSL) {
      "${fqdn}".postRun = "systemctl restart peertube.service";
    };

    services.nginx.virtualHosts = mkIf cfg.reverseProxy.enable {
      "${fqdn}" = mkVirtualHost {
        inherit config fqdn;
        ssl = cfg.reverseProxy.forceSSL;
      };
    };

    sops.secrets."peertube/secret" = {
      owner = cfg.user;
      group = cfg.group;
      mode = "0440";
    };
  };
}
