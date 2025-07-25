{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.tt-rss;
  domain = config.networking.domain;
  fqdn = if (cfg.subdomain != "") then "${cfg.subdomain}.${domain}" else domain;

  inherit (lib)
    mkAfter
    mkDefault
    mkIf
    mkOption
    types
    ;
in
{
  options.services.tt-rss = {
    subdomain = mkOption {
      type = types.str;
      default = "tt-rss";
      description = "Subdomain for the Nginx proxy.";
    };
    forceSSL = mkOption {
      type = types.bool;
      default = true;
      description = "Force SSL for Nginx virtual host.";
    };
  };

  config = {
    services.tt-rss = {
      database.type = "mysql"; # pgsql creates collation version mismatch issues
      virtualHost = mkDefault fqdn;
      selfUrlPath = mkDefault ("https://" + fqdn);
    };

    # disable admin user
    systemd.services.tt-rss.preStart = mkIf cfg.enable (mkAfter ''
      ${pkgs.php}/bin/php ${cfg.root}/www/update.php \
      --user-set-access-level "admin:-2"
    '');

    systemd.tmpfiles.rules = [ "d ${cfg.root} 0755 ${cfg.user} ${cfg.user} -" ];

    services.nginx.virtualHosts.${fqdn} = mkIf cfg.enable {
      forceSSL = cfg.forceSSL;
      enableACME = cfg.forceSSL;
    };

    # Script for user management
    environment.systemPackages = [ (import ./tt-rss-users.nix { inherit config pkgs; }) ];
  };
}
