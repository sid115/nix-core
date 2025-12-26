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
    mkIf
    ;

  inherit (lib.utils)
    mkReverseProxyOption
    mkVirtualHost
    mkUrl
    ;
in
{
  options.services.gitea = {
    reverseProxy = mkReverseProxyOption "Gitea" "git";
  };

  config = mkIf cfg.enable {
    services.gitea = {
      appName = mkDefault "gitea";
      settings = {
        session.COOKIE_SECURE = mkDefault true;
        service.DISABLE_REGISTRATION = mkDefault true;
        server = {
          DOMAIN = mkDefault fqdn;
          ROOT_URL = mkDefault (mkUrl {
            inherit fqdn;
            ssl = with cfg.reverseProxy; enable && forceSSL;
          });
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

    services.nginx.virtualHosts = mkIf cfg.reverseProxy.enable {
      "${fqdn}" = mkVirtualHost {
        inherit config fqdn;
        port = cfg.settings.server.HTTP_PORT;
        ssl = cfg.reverseProxy.forceSSL;
      };
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
