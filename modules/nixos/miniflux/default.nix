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
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in
{
  options.services.miniflux = {
    reverseProxy = {
      enable = mkEnableOption "Nginx reverse proxy for Miniflux";
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

    services.nginx.virtualHosts."${fqdn}" = mkIf cfg.reverseProxy.enable {
      enableACME = cfg.reverseProxy.forceSSL;
      forceSSL = cfg.reverseProxy.forceSSL;
      locations."/" = {
        proxyPass = mkDefault "http://127.0.0.1:${toString cfg.config.PORT}";
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
