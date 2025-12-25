{
  config,
  lib,
  ...
}:

let
  cfg = config.services.immich;
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
  options.services.immich = {
    reverseProxy = {
      enable = mkEnableOption "Nginx reverse proxy for immich";
      subdomain = mkOption {
        type = types.str;
        default = "gallery";
        description = "Subdomain for Nginx virtual host. Leave empty for root domain.";
      };
      forceSSL = mkOption {
        type = types.bool;
        default = true;
        description = "Force SSL for Nginx virtual host.";
      };
      maxBodySize = mkOption {
        type = types.str;
        default = "5G";
        description = "Maximum body size for uploads.";
      };
    };
  };

  config = mkIf cfg.enable {
    services.immich = {
      port = mkDefault 2283;
      host = mkDefault (if cfg.reverseProxy.enable then "127.0.0.1" else "0.0.0.0");
      secretsFile = config.sops.templates."immich/secrets-file".path;
      settings = {
        server.externalDomain =
          if config.nginx.virtualHosts."${fqdn}".forceSSL then "https://${fqdn}" else "http://${fqdn}";
      };
    };

    services.nginx.virtualHosts."${fqdn}" = mkIf cfg.reverseProxy.enable {
      forceSSL = cfg.reverseProxy.forceSSL;
      enableACME = cfg.reverseProxy.forceSSL;
      locations."/".proxyPass = mkDefault "http://127.0.0.1:${toString cfg.port}";
      extraConfig = ''
        client_max_body_size ${cfg.reverseProxy.maxBodySize};
      '';
    };

    sops =
      let
        owner = cfg.user;
        group = cfg.group;
        mode = "0440";
      in
      {
        secrets."immich/db-password" = {
          inherit owner group mode;
        };
        templates."immich/secrets-file" = {
          inherit owner group mode;
          content = ''
            DB_PASSWORD=${config.sops.placeholder."immich/db-password"}
          '';
        };
      };
  };
}
