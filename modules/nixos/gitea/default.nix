{
  config,
  lib,
  ...
}:

let
  cfg = config.services.gitea;
  domain = config.networking.domain;
  fqdn = if (isNotEmptyStr cfg.subdomain) then "${cfg.subdomain}.${domain}" else domain;

  inherit (lib)
    elemAt
    isNotEmptyStr
    mkDefault
    mkIf
    mkOption
    types
    ;
in
{
  options.services.gitea = {
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

  config = mkIf cfg.enable {
    services.gitea = {
      appName = mkDefault "gitea";
      settings = {
        session.COOKIE_SECURE = mkDefault true;
        service.DISABLE_REGISTRATION = mkDefault true;
        server = {
          DOMAIN = mkDefault fqdn;
          ROOT_URL = mkDefault "https://${fqdn}";
          HTTP_ADDR = mkDefault "127.0.0.1";
          SSH_PORT = mkDefault (elemAt config.services.openssh.ports 0);
          DEFAULT_THEME = mkDefault "arc-green";
        };
        database.type = mkDefault "postgres";
      };
    };

    systemd.tmpfiles.rules = [ "d ${cfg.stateDir} 0755 ${cfg.user} ${cfg.group} -" ];

    security.acme.certs."${fqdn}".postRun = mkIf cfg.forceSSL "systemctl restart gitea.service";

    services.nginx.virtualHosts."${fqdn}" = {
      enableACME = cfg.forceSSL;
      forceSSL = cfg.forceSSL;
      locations."/".proxyPass = mkDefault ("http://localhost:${toString cfg.settings.server.HTTP_PORT}");
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
