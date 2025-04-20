{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.nextcloud;
  fqdn = "${cfg.subdomain}.${config.networking.domain}";
  mailserver = config.mailserver;

  inherit (lib)
    mkDefault
    mkIf
    mkOption
    types
    ;
in
{
  options.services.nextcloud = {
    subdomain = mkOption {
      type = types.str;
      default = "nc";
      description = "Subdomain for Nginx virtual host.";
    };
    forceSSL = mkOption {
      type = types.bool;
      default = true;
      description = "Force SSL for Nginx virtual host.";
    };
  };

  config = mkIf cfg.enable {
    environment.etc."secrets/nextcloud-initial-admin-pass".text = "nextcloud";

    services.nextcloud = {
      package = pkgs.nextcloud30;
      hostName = fqdn;
      https = cfg.forceSSL;
      config = {
        adminuser = mkDefault "nextcloud";
        adminpassFile = mkDefault "/etc/secrets/nextcloud-initial-admin-pass";
      };
      configureRedis = mkDefault true;
      extraAppsEnable = mkDefault true;
      appstoreEnable = mkDefault false;
      webfinger = mkDefault true;
      settings = {
        dbtype = mkDefault "sqlite";

        # Logging
        log_type = mkDefault "file"; # systemd not available: https://github.com/NixOS/nixpkgs/issues/262142
        logfile = "${cfg.datadir}/data/nextcloud.log";
        loglevel = mkDefault 2;
        syslog_tag = mkDefault "Nextcloud";

        # SMTP with SSL/TLS
        mail_domain = mkDefault config.networking.domain;
        mail_from_address = mkDefault "nextcloud"; # @domain.tld gets added automatically
        mail_smtpauth = mkDefault true;
        mail_smtphost = mkDefault mailserver.fqdn;
        mail_smtpmode = mkDefault "smtp";
        mail_smtpname = mkDefault "nextcloud@${config.networking.domain}";
        mail_smtpport = mkDefault 465;
        mail_smtpsecure = mkDefault "ssl";
        mail_smtptimeout = mkDefault 30;

        maintenance_window_start = 2; # 2am UTC
        default_phone_region = mkDefault "DE";
      };
      phpOptions = {
        catch_workers_output = "yes";
        display_errors = "stderr";
        error_reporting = "E_ALL & ~E_DEPRECATED & ~E_STRICT";
        expose_php = "Off";
        "opcache.fast_shutdown" = "1";
        "opcache.interned_strings_buffer" = "16";
        "opcache.max_accelerated_files" = "10000";
        "opcache.memory_consumption" = "128";
        "opcache.revalidate_freq" = "1";
        output_buffering = "0";
        short_open_tag = "Off";
      };
      secretFile = mkIf mailserver.enable config.sops.templates."nextcloud".path;
    };

    services.nginx.virtualHosts.${cfg.hostName} = {
      forceSSL = cfg.forceSSL;
      enableACME = cfg.forceSSL;
    };

    sops = mkIf mailserver.enable {
      secrets."nextcloud/smtp-password" = {
        owner = "nextcloud";
        group = "nextcloud";
        mode = "0440";
      };
      secrets."nextcloud/hashed-smtp-password" = {
        owner = "nextcloud";
        group = "nextcloud";
        mode = "0440";
      };
      templates."nextcloud" = {
        owner = "nextcloud";
        group = "nextcloud";
        mode = "0440";
        content = ''
          {"mail_smtppassword":"${config.sops.placeholder."nextcloud/smtp-password"}"}
        '';
      };
    };

    mailserver = mkIf mailserver.enable {
      loginAccounts = {
        "nextcloud@${config.networking.domain}" = {
          hashedPasswordFile = config.sops.secrets."nextcloud/hashed-smtp-password".path;
        };
      };
    };
  };
}
