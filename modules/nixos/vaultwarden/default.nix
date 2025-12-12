{ config, lib, ... }:

let
  cfg = config.services.vaultwarden;
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
  options.services.vaultwarden = {
    reverseProxy = {
      enable = mkEnableOption "Nginx reverse proxy for vaultwarden";
      subdomain = mkOption {
        type = types.str;
        default = "pass";
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
    services.vaultwarden = {
      config = {
        ADMIN_TOKEN_FILE = mkDefault config.sops.secrets."vaultwarden/admin-token".path;
        DOMAIN = mkDefault (if cfg.reverseProxy.forceSSL then "https://${fqdn}" else "http://${fqdn}");
        ROCKET_ADDRESS = mkDefault (if cfg.reverseProxy.enable then "127.0.0.1" else "0.0.0.0");
        ROCKET_PORT = mkDefault 8222;
        SIGNUPS_ALLOWED = mkDefault false;

        SMTP_FROM = mkDefault "vaultwarden@${domain}";
        SMTP_FROM_NAME = mkDefault "${domain} Vaultwarden server";
        SMTP_HOST = mkDefault "mail.${domain}";
        SMTP_PORT = mkDefault 587;
        SMTP_SECURITY = mkDefault "starttls";
        SMTP_USERNAME = mkDefault "vaultwarden@${domain}";
        SMTP_PASSWORD_FILE = mkDefault config.sops.secrets."vaultwarden/smtp-password".path;
      };
    };

    services.nginx.virtualHosts."${fqdn}" = mkIf cfg.reverseProxy.enable {
      enableACME = cfg.reverseProxy.forceSSL;
      forceSSL = cfg.reverseProxy.forceSSL;
      locations."/".proxyPass = "http://127.0.0.1:${toString cfg.config.ROCKET_PORT}";
    };

    mailserver.loginAccounts."vaultwarden@${domain}".hashedPasswordFile =
      mkIf config.mailserver.enable
        config.sops.secrets."vaultwarden/hashed-smtp-password".path;

    sops =
      let
        owner = "vaultwarden";
        group = "vaultwarden";
        mode = "0440";
      in
      {
        secrets."vaultwarden/admin-token" = {
          inherit owner group mode;
        };
        secrets."vaultwarden/smtp-password" = {
          inherit owner group mode;
        };
        secrets."vaultwarden/hashed-smtp-password" = mkIf config.mailserver.enable {
          inherit owner group mode;
        };
      };
  };
}
