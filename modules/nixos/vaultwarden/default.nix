{ config, lib, ... }:

let
  cfg = config.services.vaultwarden;
  domain = config.networking.domain;
  subdomain = cfg.reverseProxy.subdomain;
  fqdn = if (cfg.reverseProxy.enable && subdomain != "") then "${subdomain}.${domain}" else domain;

  inherit (lib)
    mkDefault
    mkIf
    ;

  inherit (lib.utils)
    mkReverseProxyOption
    mkVirtualHost
    mkUrl
    ;
in
{
  options.services.vaultwarden = {
    reverseProxy = mkReverseProxyOption "Vaultwarden" "pass";
  };

  config = mkIf cfg.enable {
    services.vaultwarden = {
      config = {
        ADMIN_TOKEN_FILE = mkDefault config.sops.secrets."vaultwarden/admin-token".path;
        DOMAIN = mkDefault (mkUrl {
          inherit fqdn;
          ssl = with cfg.reverseProxy; enable && forceSSL;
        });
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

    services.nginx.virtualHosts = mkIf cfg.reverseProxy.enable {
      "${fqdn}" = mkVirtualHost {
        inherit config fqdn;
        port = cfg.config.ROCKET_PORT;
        ssl = cfg.reverseProxy.forceSSL;
      };
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
