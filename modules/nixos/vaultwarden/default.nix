{ config, lib, ... }:

let
  cfg = config.services.vaultwarden;
  fqdn = "${cfg.subdomain}.${config.networking.domain}";

  inherit (lib)
    mkDefault
    mkIf
    mkOption
    types
    ;
in
{
  options.services.vaultwarden = {
    subdomain = mkOption {
      type = types.str;
      default = "pass";
      description = "Subdomain for Nginx virtual host.";
    };
    forceSSL = mkOption {
      type = types.bool;
      default = true;
      description = "Force SSL for Nginx virtual host.";
    };
    port = mkOption {
      type = types.int;
      default = 8222;
      description = "Port for web interface used by Nginx proxy.";
    };
  };

  config = mkIf cfg.enable {
    services.vaultwarden = {
      config = {
        ADMIN_TOKEN_FILE = mkDefault config.sops.secrets."vaultwarden/admin-token".path;
        DOMAIN = mkDefault "https://${fqdn}";
        ROCKET_ADDRESS = mkDefault "127.0.0.1";
        ROCKET_PORT = cfg.port;
        SIGNUPS_ALLOWED = mkDefault false;

        SMTP_FROM = mkDefault "vaultwarden@${config.networking.domain}";
        SMTP_FROM_NAME = mkDefault "${config.networking.domain} Vaultwarden server";
        SMTP_HOST = mkDefault "mail.${config.networking.domain}";
        SMTP_PORT = mkDefault 587;
        SMTP_SECURITY = mkDefault "starttls";
        SMTP_USERNAME = mkDefault "vaultwarden@${config.networking.domain}";
        SMTP_PASSWORD_FILE =
          mkIf config.mailserver.enable
            config.sops.secrets."vaultwarden/smtp-password".path;
      };
    };

    services.nginx.virtualHosts."${fqdn}" = {
      enableACME = cfg.forceSSL;
      forceSSL = cfg.forceSSL;
      locations."/".proxyPass = "http://127.0.0.1:${toString cfg.port}";
    };

    mailserver.loginAccounts."vaultwarden@${config.networking.domain}".hashedPasswordFile =
      mkIf config.mailserver.enable
        config.sops.secrets."vaultwarden/hashed-smtp-password".path;

    sops = {
      secrets."vaultwarden/admin-token" = {
        owner = "vaultwarden";
        group = "vaultwarden";
        mode = "0440";
      };
      secrets."vaultwarden/smtp-password" = mkIf config.mailserver.enable {
        owner = "vaultwarden";
        group = "vaultwarden";
        mode = "0440";
      };
      secrets."vaultwarden/hashed-smtp-password" = mkIf config.mailserver.enable {
        owner = "vaultwarden";
        group = "vaultwarden";
        mode = "0440";
      };
    };
  };
}
