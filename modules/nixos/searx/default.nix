{ config, lib, ... }:

let
  cfg = config.services.searx;
  domain = config.networking.domain;
  subdomain = cfg.reverseProxy.subdomain;
  fqdn = if (cfg.reverseProxy.enable && subdomain != "") then "${subdomain}.${domain}" else domain;

  inherit (lib)
    mkDefault
    mkForce
    mkIf
    ;

  inherit (lib.utils)
    mkReverseProxyOption
    mkVirtualHost
    mkUrl
    ;
in
{
  options.services.searx = {
    reverseProxy = mkReverseProxyOption "Searx" "srx";
  };

  config = mkIf cfg.enable {
    services.searx = {
      redisCreateLocally = mkDefault true;
      configureUwsgi = mkForce false;
      environmentFile = config.sops.templates."searx/env-file".path;
      settings = {
        debug = mkDefault false;
        privacypolicy_url = mkDefault false;
        donation_url = mkDefault false;
        contact_url = mkDefault false;
        enable_metrics = mkDefault false;
        server = {
          bind_address = mkDefault (if cfg.reverseProxy.enable then "127.0.0.1" else "0.0.0.0");
          port = mkDefault 8787;
          secret_key = mkDefault "@SEARX_SECRET_KEY@";
          base_url = mkDefault (mkUrl {
            inherit fqdn;
            ssl = with cfg.reverseProxy; enable && forceSSL;
          });
          limiter = mkDefault true;
        };
        search = {
          formats = mkDefault [
            "html"
            "json"
          ];
        };
      };
      limiterSettings = {
        botdetection = {
          ipv4_prefix = mkDefault 32;
          ipv6_prefix = mkDefault 48;
          trusted_proxies = mkDefault [
            "127.0.0.0/8"
            "::1"
          ];
          ip_limit = {
            filter_link_local = mkDefault false;
            link_token = mkDefault false;
          };
          pass_searxng_org = mkDefault true;
        };
      };
    };

    services.nginx.virtualHosts = mkIf cfg.reverseProxy.enable {
      "${fqdn}" = mkVirtualHost {
        inherit config fqdn;
        port = cfg.settings.server.port;
        ssl = cfg.reverseProxy.forceSSL;
      };
    };

    sops =
      let
        owner = "searx";
        group = "searx";
        mode = "0440";
      in
      {
        secrets."searx/secret-key" = {
          inherit owner group mode;
        };
        templates."searx/env-file" = {
          inherit owner group mode;
          content = ''
            SEARX_SECRET_KEY=${config.sops.placeholder."searx/secret-key"}
          '';
        };
      };
  };
}
