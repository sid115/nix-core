{
  config,
  lib,
  ...
}:

let
  cfg = config.services.immich;
  domain = config.networking.domain;
  fqdn = if (cfg.subdomain != "") then "${cfg.subdomain}.${domain}" else domain;

  inherit (lib)
    mkDefault
    mkIf
    mkOption
    types
    ;
in
{
  options.services.immich = {
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
  };

  config = mkIf cfg.enable {
    services.immich = {
      port = mkDefault 2283;
      secretsFile = config.sops.templates."immich/secrets-file".path;
      settings = {
        server.externalDomain = if cfg.forceSSL then "https://${fqdn}" else "http://${fqdn}";
      };
    };

    services.nginx.virtualHosts.${fqdn} = {
      forceSSL = cfg.forceSSL;
      enableACME = cfg.forceSSL;
      locations."/".proxyPass = mkDefault "http://localhost:${builtins.toString cfg.port}";
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
