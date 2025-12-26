{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.nextcloud;
  domain = config.networking.domain;
  subdomain = cfg.reverseProxy.subdomain;
  fqdn = if (cfg.reverseProxy.enable && subdomain != "") then "${subdomain}.${domain}" else domain;

  # package = pkgs.nextcloud31.overrideAttrs (old: rec {
  #   version = "31.0.7";
  #   src = pkgs.fetchurl {
  #     url = "https://download.nextcloud.com/server/releases/nextcloud-${version}.tar.bz2";
  #     hash = "sha256-ACpdA64Fp/DDBWlH1toLeaRNPXIPVyj+UVWgxaO07Gk=";
  #   };
  # });

  inherit (lib)
    mkDefault
    mkIf
    ;

  inherit (lib.utils)
    mkMailIntegrationOption
    mkReverseProxyOption
    mkVirtualHost
    ;
in
{
  options.services.nextcloud = {
    mailIntegration = mkMailIntegrationOption "Nextcloud";
    reverseProxy = mkReverseProxyOption "Nextcloud" "nc";
  };

  config = mkIf cfg.enable {
    environment = {
      etc."secrets/nextcloud-initial-admin-pass".text = "nextcloud";
      systemPackages = [ pkgs.sqlite ]; # TODO: switch to postgresql
    };

    services.nextcloud = {
      # inherit package;
      hostName = fqdn;
      https = if cfg.reverseProxy.enable then cfg.reverseProxy.forceSSL else mkDefault false;
      config = {
        adminuser = mkDefault "nextcloud";
        adminpassFile = mkDefault "/etc/secrets/nextcloud-initial-admin-pass";
        dbtype = mkDefault "sqlite"; # TODO: switch to postgresql
      };
      configureRedis = mkDefault true;
      extraAppsEnable = mkDefault true;
      appstoreEnable = mkDefault false;
      webfinger = mkDefault true;
      settings = {
        # Logging
        log_type = mkDefault "systemd";
        loglevel = mkDefault 2;
        syslog_tag = mkDefault "Nextcloud";

        maintenance_window_start = 2; # 2am UTC
        default_phone_region = mkDefault "DE";
      }
      // mkIf cfg.mailIntegration.enable {
        # SMTP with SSL/TLS
        mail_domain = mkDefault domain;
        mail_from_address = mkDefault "nextcloud"; # @domain.tld gets added automatically
        mail_smtpauth = mkDefault true;
        mail_smtphost = mkDefault cfg.mailIntegration.smtpHost;
        mail_smtpmode = mkDefault "smtp";
        mail_smtpname = mkDefault "nextcloud@${domain}";
        mail_smtpport = mkDefault 465;
        mail_smtpsecure = mkDefault "ssl";
        mail_smtptimeout = mkDefault 30;
      };
      phpOptions = {
        catch_workers_output = "yes";
        display_errors = "stderr";
        error_reporting = "E_ALL & ~E_DEPRECATED & ~E_STRICT";
        expose_php = "Off";
        "opcache.fast_shutdown" = "1";
        "opcache.interned_strings_buffer" = "64";
        "opcache.max_accelerated_files" = "10000";
        "opcache.memory_consumption" = "512";
        "opcache.revalidate_freq" = "1";
        output_buffering = "0";
        short_open_tag = "Off";
      };
      secretFile = mkIf cfg.mailIntegration.enable config.sops.templates."nextcloud".path;
    };

    services.nginx.virtualHosts = mkIf cfg.reverseProxy.enable {
      "${cfg.hostName}" = mkVirtualHost {
        inherit config fqdn;
        ssl = cfg.reverseProxy.forceSSL;
      };
    };

    sops = mkIf cfg.mailIntegration.enable (
      let
        owner = "nextcloud";
        group = "nextcloud";
        mode = "0440";
      in
      {
        secrets."nextcloud/smtp-password" = {
          inherit owner group mode;
        };
        templates."nextcloud" = {
          inherit owner group mode;
          content = ''
            {"mail_smtppassword":"${config.sops.placeholder."nextcloud/smtp-password"}"}
          '';
        };
      }
    );
  };
}
