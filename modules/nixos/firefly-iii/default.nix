{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.firefly-iii;
  importer-cfg = config.services.firefly-iii-data-importer;
  fqdn =
    if (cfg.subdomain != "") then
      "${cfg.subdomain}.${config.networking.domain}"
    else
      config.networking.domain;
  importer-fqdn =
    if (cfg.importer-subdomain != "") then
      "${cfg.importer-subdomain}.${config.networking.domain}"
    else
      throw "No subdomain specified for Firefly-III data importer.";
  mailserver = config.mailserver;

  inherit (lib)
    mkDefault
    mkIf
    mkOption
    types
    ;
in
{
  options.services.firefly-iii = {
    subdomain = mkOption {
      type = types.str;
      default = "finance";
      description = "Subdomain for Nginx virtual host (Firefly-III).";
    };
    forceSSL = mkOption {
      type = types.bool;
      default = true;
      description = "Force SSL for Nginx virtual host.";
    };
    importer-subdomain = mkOption {
      type = types.str;
      default = "import.finance";
      description = "Subdomain for Nginx virtual host (Firefly-III data importer).";
    };
  };

  config = mkIf cfg.enable {
    services.firefly-iii = {
      enableNginx = true;
      virtualHost = fqdn;
      settings = {
        APP_ENV = "production";
        APP_FORCE_ROOT = if cfg.forceSSL then "https://${cfg.virtualHost}" else "http://${cfg.virtualHost}";
        APP_FORCE_SSL = cfg.forceSSL;
        APP_KEY_FILE = config.sops.templates."firefly-iii/appkey".path;
        APP_URL = if cfg.forceSSL then "https://${cfg.virtualHost}" else "http://${cfg.virtualHost}";
        DB_CONNECTION = "mysql";
        DB_DATABASE = "firefly";
        DB_HOST = "localhost";
        DB_PASSWORD = "";
        DB_PORT = 3306;
        DB_USERNAME = "firefly-iii";
        TRUSTED_PROXIES = "**";

        MAIL_MAILER = "smtp";
        MAIL_HOST = mkDefault mailserver.fqdn;
        MAIL_PORT = mkDefault 465;
        MAIL_FROM = mkDefault "${cfg.subdomain}@${config.networking.domain}";
        MAIL_USERNAME = mkDefault "${cfg.subdomain}@${config.networking.domain}";
        MAIL_PASSWORD_FILE = config.sops.secrets."firefly-iii/smtp-password".path;
        MAIL_ENCRYPTION = mkDefault "ssl";
      };
    };

    services.firefly-iii-data-importer = {
      enable = mkDefault true;
      enableNginx = true;
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

    services.nginx.virtualHosts = {
      "${cfg.virtualHost}" = {
        enableACME = cfg.forceSSL;
        forceSSL = cfg.forceSSL;
      };
      "${importer-cfg.virtualHost}" = {
        enableACME = cfg.forceSSL;
        forceSSL = cfg.forceSSL;
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

    sops = {
      secrets."firefly-iii/appkey" = {
        owner = cfg.user;
        group = cfg.group;
        mode = "0440";
      };
      templates."firefly-iii/appkey" = {
        owner = cfg.user;
        group = cfg.group;
        mode = "0440";
        content = ''
          base64:${config.sops.placeholder."firefly-iii/appkey"}
        '';
      };
      secrets."firefly-iii/smtp-password" = mkIf mailserver.enable {
        owner = cfg.user;
        group = cfg.group;
        mode = "0440";
      };
      secrets."firefly-iii/hashed-smtp-password" = mkIf mailserver.enable {
        owner = cfg.user;
        group = cfg.group;
        mode = "0440";
      };
    };
  };
}
