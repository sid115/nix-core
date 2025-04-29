{ config, lib, ... }:

let
  cfg = config.services.searx;
  fqdn = "${cfg.subdomain}.${config.networking.domain}";

  inherit (lib)
    mkDefault
    mkIf
    mkOption
    types
    ;
in
{
  options.services.searx = {
    subdomain = mkOption {
      type = types.str;
      default = "srx";
      description = "Subdomain for Nginx virtual host.";
    };
    forceSSL = mkOption {
      type = types.bool;
      default = true;
      description = "Force SSL for Nginx virtual host.";
    };
  };

  config = mkIf cfg.enable {
    services.searx = {
      redisCreateLocally = mkDefault true;
      runInUwsgi = mkDefault true;
      settings = {
        debug = mkDefault false;
        privacypolicy_url = mkDefault false;
        donation_url = mkDefault false;
        contact_url = mkDefault false;
        enable_metrics = mkDefault false;
        server = {
          bind_address = mkDefault "127.0.0.1";
          secret_key = mkDefault "searx_secret_key"; # FIXME
          base_url = mkDefault "https://${fqdn}";
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
        botdetection.ip_lists.pass_ip = mkDefault [ "127.0.0.1" ];
      };
    };

    services.nginx.virtualHosts."${fqdn}" = {
      enableACME = cfg.forceSSL;
      forceSSL = cfg.forceSSL;
      locations."/".proxyPass = "http://localhost:${toString cfg.settings.server.port}";
    };
  };
}
