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
    mkIf
    mkOption
    types
    ;

  inherit (lib.utils)
    mkReverseProxyOption
    mkUrl
    mkVirtualHost
    ;
in
{
  options.services.immich = {
    reverseProxy = mkReverseProxyOption "Immich" "gallery" // {
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
        server.externalDomain = mkUrl {
          inherit fqdn;
          ssl = with cfg.reverseProxy; enable && forceSSL;
        };
      };
    };

    services.nginx.virtualHosts = mkIf cfg.reverseProxy.enable {
      "${fqdn}" =
        mkVirtualHost {
          inherit config fqdn;
          port = cfg.port;
          ssl = cfg.reverseProxy.forceSSL;
        }
        // {
          extraConfig = ''
            client_max_body_size ${cfg.reverseProxy.maxBodySize};
          '';
        };
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
