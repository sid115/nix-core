{
  config,
  lib,
  ...
}:

let
  cfg = config.services.gitea;
  domain = config.networking.domain;
  subdomain = cfg.reverseProxy.subdomain;
  fqdn = if (cfg.reverseProxy.enable && subdomain != "") then "${subdomain}.${domain}" else domain;

  inherit (lib)
    elemAt
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in
{
  options.services.gitea = {
    reverseProxy = {
      enable = mkEnableOption "Nginx reverse proxy for gitea";
      subdomain = mkOption {
        type = types.str;
        default = "git";
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
    services.gitea = {
      appName = mkDefault "gitea";
      settings = {
        session.COOKIE_SECURE = mkDefault true;
        service.DISABLE_REGISTRATION = mkDefault true;
        server = {
          DOMAIN = mkDefault fqdn;
          ROOT_URL = mkDefault (if cfg.reverseProxy.forceSSL then "https://${fqdn}" else "http://${fqdn}");
          HTTP_ADDR = mkDefault (if cfg.reverseProxy.enable then "127.0.0.1" else "0.0.0.0");
          HTTP_PORT = mkDefault 3000;
          SSH_PORT = mkDefault (elemAt config.services.openssh.ports 0);
          DEFAULT_THEME = mkDefault "arc-green";
        };
        database.type = mkDefault "postgres";
        mailer.SENDMAIL_PATH = "/run/wrappers/bin/sendmail"; # https://github.com/NixOS/nixpkgs/issues/421484
      };
    };

    systemd.tmpfiles.rules = [ "d ${cfg.stateDir} 0755 ${cfg.user} ${cfg.group} -" ];

    security.acme.certs = mkIf (with cfg.reverseProxy; enable && forceSSL) {
      "${fqdn}".postRun = "systemctl restart gitea.service";
    };

    services.nginx.virtualHosts."${fqdn}" = mkIf cfg.reverseProxy.enable {
      enableACME = cfg.reverseProxy.forceSSL;
      forceSSL = cfg.reverseProxy.forceSSL;
      locations."/" = {
        proxyPass = mkDefault "http://127.0.0.1:${toString cfg.settings.server.HTTP_PORT}";
      };
      sslCertificate = mkIf cfg.reverseProxy.forceSSL "${
        config.security.acme.certs."${fqdn}".directory
      }/cert.pem";
      sslCertificateKey = mkIf cfg.reverseProxy.forceSSL "${
        config.security.acme.certs."${fqdn}".directory
      }/key.pem";
    };

    services.postgresql = {
      ensureDatabases = mkDefault [ cfg.database.name ];
      ensureUsers = mkDefault [
        {
          name = cfg.database.user;
          ensureDBOwnership = true;
        }
      ];
    };

    environment.shellAliases = {
      gitea = "sudo -u gitea ${cfg.package} --config ${cfg.stateDir}/custom/conf/app.ini";
    };
  };
}
