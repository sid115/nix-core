{ config, lib, ... }:

let
  cfg = config.services.rss-bridge;
  domain = config.networking.domain;
  fqdn = if (isNotEmptyStr cfg.subdomain) then "${cfg.subdomain}.${domain}" else domain;

  inherit (lib)
    mkIf
    mkOption
    types
    ;

  isNotEmptyStr = (import ../../../lib).isNotEmptyStr; # FIXME: cannot get lib overlay to work
in
{
  options.services.rss-bridge = {
    subdomain = mkOption {
      type = types.str;
      default = "rss";
      description = "Subdomain for Nginx virtual host. Leave empty for root domain.";
    };
    forceSSL = mkOption {
      type = types.bool;
      default = true;
      description = "Force SSL for Nginx virtual host.";
    };
  };

  config = mkIf cfg.enable {
    services.rss-bridge = {
      virtualHost = fqdn;
      config = {
        system.enabled_bridges = [ "*" ];
      };
    };

    systemd.tmpfiles.rules = [ "d ${cfg.dataDir} 0755 ${cfg.user} ${cfg.group} -" ];

    services.nginx.virtualHosts."${fqdn}" = {
      forceSSL = cfg.forceSSL;
      enableACME = cfg.forceSSL;
    };
  };
}
