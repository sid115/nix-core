{ config, lib, ... }:

let
  cfg = config.services.uptime-kuma;
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
  options.services.uptime-kuma = {
    subdomain = mkOption {
      type = types.str;
      default = "monitor";
      description = "Subdomain for Nginx virtual host. Leave empty for root domain.";
    };
    forceSSL = mkOption {
      type = types.bool;
      default = true;
      description = "Force SSL for Nginx virtual host.";
    };
  };

  config = mkIf cfg.enable {
    services.uptime-kuma = {
      settings = {
        HOST = mkDefault "127.0.0.1";
        PORT = mkDefault "3001";
      };
    };

    services.nginx.virtualHosts."${fqdn}" = {
      forceSSL = cfg.forceSSL;
      enableACME = cfg.forceSSL;
      locations."/" = {
        proxyPass = mkDefault (with cfg.settings; "http://${HOST}:${PORT}");
      };
    };
  };
}
