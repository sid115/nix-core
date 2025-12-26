{
  config,
  lib,
  ...
}:

let
  cfg = config.services.miniflux;
  domain = config.networking.domain;
  subdomain = cfg.reverseProxy.subdomain;
  fqdn = if (cfg.reverseProxy.enable && subdomain != "") then "${subdomain}.${domain}" else domain;
  port = 8085;

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
  options.services.miniflux = {
    reverseProxy = mkReverseProxyOption "Miniflux" "rss";
  };

  config = mkIf cfg.enable {
    services.miniflux = {
      adminCredentialsFile = config.sops.templates."miniflux/admin-credentials".path;
      createDatabaseLocally = mkDefault true;
      config = {
        ADMIN_USERNAME = mkDefault "admin";
        CREATE_ADMIN = mkDefault 1;
        LISTEN_ADDR = mkDefault "127.0.0.1:${toString port}";
        PORT = mkIf cfg.reverseProxy.enable (mkDefault port); # overrides LISTEN_ADDR to "0.0.0.0:${PORT}"
      };
    };

    services.nginx.virtualHosts = mkIf cfg.reverseProxy.enable {
      "${fqdn}" = mkVirtualHost {
        inherit config fqdn;
        port = cfg.config.PORT;
        ssl = cfg.reverseProxy.forceSSL;
      };
    };

    sops = {
      secrets."miniflux/admin-password" = { };
      templates."miniflux/admin-credentials" = {
        content = ''
          ADMIN_USERNAME=${cfg.config.ADMIN_USERNAME}
          ADMIN_PASSWORD=${config.sops.placeholder."miniflux/admin-password"}
        '';
      };
    };
  };
}
