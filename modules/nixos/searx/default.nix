{ config, lib, ... }:

let
  cfg = config.services.searx;
  domain = config.networking.domain;
  fqdn = if (cfg.subdomain != "") then "${cfg.subdomain}.${domain}" else domain;

  inherit (lib)
    mkDefault
    mkForce
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
      description = "Subdomain for Nginx virtual host. Leave empty for root domain.";
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
      runInUwsgi = mkForce false;
      environmentFile = config.sops.templates."searx/env-file".path;
      settings = {
        debug = mkDefault false;
        privacypolicy_url = mkDefault false;
        donation_url = mkDefault false;
        contact_url = mkDefault false;
        enable_metrics = mkDefault false;
        server = {
          bind_address = mkDefault "127.0.0.1";
          port = mkDefault 8787;
          secret_key = mkDefault "@SEARX_SECRET_KEY@";
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
      locations."/".proxyPass = mkDefault "http://localhost:${toString cfg.settings.server.port}";
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
            SEARX_SECRET_KEY=${config.sops.placeholder."searx/secret-key".path}
          '';
        };
      };
  };
}
