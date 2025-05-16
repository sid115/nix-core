{ config, lib, ... }:

let
  cfg = config.services.peertube;
  domain = config.networking.domain;
  fqdn = if (isNotEmptyStr cfg.subdomain) then "${cfg.subdomain}.${domain}" else domain;

  inherit (lib)
    isNotEmptyStr
    mkDefault
    mkIf
    mkOption
    types
    ;
in
{
  options.services.peertube = {
    subdomain = mkOption {
      type = types.str;
      default = "vid";
      description = "Subdomain for Nginx virtual host. Leave empty for root domain.";
    };
    forceSSL = mkOption {
      type = types.bool;
      default = true;
      description = "Force SSL for Nginx virtual host.";
    };
  };

  config = mkIf cfg.enable {
    services.peertube = {
      localDomain = fqdn;
      enableWebHttps = cfg.forceSSL;
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

    security.acme.certs."${fqdn}".postRun = mkIf cfg.forceSSL "systemctl restart peertube.service";

    services.nginx.virtualHosts."${fqdn}" = {
      enableACME = cfg.forceSSL;
      forceSSL = cfg.forceSSL;
      locations."/".proxyPass = mkDefault "http://localhost:${toString cfg.listenWeb}";
    };

    sops.secrets."peertube/secret" = {
      owner = "peertube";
      group = "peertube";
      mode = "0440";
    };
  };
}
