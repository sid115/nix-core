{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.firefly-iii;
  importer-cfg = config.services.firefly-iii-data-importer;
  domain = config.networking.domain;
  mailserver = config.mailserver;

  inherit (cfg.reverseProxy) subdomain importerSubdomain;
  fqdn = if (subdomain != "") then "${subdomain}.${domain}" else domain;
  importer-fqdn =
    if (importerSubdomain != "") then
      "${importerSubdomain}.${domain}"
    else
      throw "No subdomain specified for Firefly-III data importer.";

  inherit (lib)
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in
{
  options.services.firefly-iii = {
    reverseProxy = {
      enable = mkEnableOption "Nginx reverse proxy for Firefly-III";
      subdomain = mkOption {
        type = types.str;
        default = "finance";
        description = "Subdomain for Nginx virtual host (Firefly-III). Leave empty for root domain.";
      };
      importerSubdomain = mkOption {
        type = types.str;
        default = "import.finance";
        description = "Subdomain for Nginx virtual host (Firefly-III data importer).";
      };
      forceSSL = mkOption {
        type = types.bool;
        default = true;
        description = "Force SSL for Nginx virtual host.";
      };
    };
  };

  config = mkIf cfg.enable {
    services.firefly-iii = {
      enableNginx = cfg.reverseProxy.enable;
      virtualHost = fqdn;
      settings = {
        APP_ENV = "production";
        APP_FORCE_ROOT =
          if cfg.reverseProxy.forceSSL then "https://${cfg.virtualHost}" else "http://${cfg.virtualHost}";
        APP_FORCE_SSL = cfg.reverseProxy.forceSSL;
        APP_KEY_FILE = config.sops.templates."firefly-iii/appkey".path;
        APP_URL =
          if cfg.reverseProxy.forceSSL then "https://${cfg.virtualHost}" else "http://${cfg.virtualHost}";
        DB_CONNECTION = mkDefault "mysql";
        DB_DATABASE = mkDefault "firefly";
        DB_HOST = mkDefault "localhost";
        DB_PASSWORD = mkDefault "";
        DB_PORT = mkDefault 3306;
        DB_USERNAME = mkDefault "firefly-iii";
        TRUSTED_PROXIES = mkDefault "**";

        MAIL_MAILER = "smtp";
        MAIL_HOST = mkDefault mailserver.fqdn;
        MAIL_PORT = mkDefault 465;
        MAIL_FROM = mkDefault "${cfg.reverseProxy.subdomain}@${domain}";
        MAIL_USERNAME = mkDefault "${cfg.reverseProxy.subdomain}@${domain}";
        MAIL_PASSWORD_FILE = config.sops.secrets."firefly-iii/smtp-password".path;
        MAIL_ENCRYPTION = mkDefault "ssl";
      };
    };

    services.firefly-iii-data-importer = {
      enable = mkDefault true;
      enableNginx = cfg.reverseProxy.enable;
      virtualHost = importer-fqdn;
      settings = {
        APP_ENV = mkDefault "local";
        LOG_CHANNEL = mkDefault "syslog";
        TZ = mkDefault "Europe/Amsterdam";
      };
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0755 ${cfg.user} ${config.services.nginx.group} -"
      "d ${importer-cfg.dataDir} 0755 ${importer-cfg.user} ${config.services.nginx.group} -"
    ];

    services.nginx.virtualHosts = mkIf cfg.reverseProxy.enable {
      "${cfg.virtualHost}" = {
        enableACME = cfg.reverseProxy.forceSSL;
        forceSSL = cfg.reverseProxy.forceSSL;
        sslCertificate = mkIf cfg.reverseProxy.forceSSL "${
          config.security.acme.certs."${fqdn}".directory
        }/cert.pem";
        sslCertificateKey = mkIf cfg.reverseProxy.forceSSL "${
          config.security.acme.certs."${fqdn}".directory
        }/key.pem";
      };
      "${importer-cfg.virtualHost}" = {
        enableACME = cfg.reverseProxy.forceSSL;
        forceSSL = cfg.reverseProxy.forceSSL;
        sslCertificate = mkIf cfg.reverseProxy.forceSSL "${
          config.security.acme.certs."${importer-fqdn}".directory
        }/cert.pem";
        sslCertificateKey = mkIf cfg.reverseProxy.forceSSL "${
          config.security.acme.certs."${importer-fqdn}".directory
        }/key.pem";
      };
    };

    services.mysql =
      let
        inherit (cfg) settings;
      in
      {
        enable = true;
        package = pkgs.mariadb;
        ensureDatabases = [ settings.DB_DATABASE ];
        ensureUsers = [
          {
            name = settings.DB_USERNAME;
            ensurePermissions = {
              "${settings.DB_DATABASE}.*" = "ALL PRIVILEGES";
            };
          }
        ];
      };

    mailserver.loginAccounts."${cfg.settings.MAIL_USERNAME}".hashedPasswordFile =
      mkIf mailserver.enable
        config.sops.secrets."firefly-iii/hashed-smtp-password".path;

    sops =
      let
        owner = cfg.user;
        group = cfg.group;
        mode = "0440";
      in
      {
        secrets."firefly-iii/appkey" = {
          inherit owner group mode;
        };
        templates."firefly-iii/appkey" = {
          inherit owner group mode;
          content = ''
            base64:${config.sops.placeholder."firefly-iii/appkey"}
          '';
        };
        secrets."firefly-iii/smtp-password" = mkIf mailserver.enable {
          inherit owner group mode;
        };
        secrets."firefly-iii/hashed-smtp-password" = mkIf mailserver.enable {
          inherit owner group mode;
        };
      };
  };
}
