{
  config,
  lib,
  ...
}:

let
  cfg = config.services.miniflux;
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
  options.services.miniflux = {
    reverseProxy = {
      enable = mkEnableOption "Nginx reverse proxy for Open WebUI.";
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
        LISTEN_ADDR = mkDefault "127.0.0.1:8085";
      };
    };

    services.nginx.virtualHosts."${fqdn}" = mkIf cfg.reverseProxy.enable {
      enableACME = cfg.reverseProxy.forceSSL;
      forceSSL = cfg.reverseProxy.forceSSL;
      locations."/" = {
        proxyPass = mkDefault "http://${toString cfg.config.LISTEN_ADDR}";
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
