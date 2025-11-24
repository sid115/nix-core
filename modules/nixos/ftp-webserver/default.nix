{ config, lib, ... }:

let
  cfg = config.services.ftp-webserver;
  domain = config.networking.domain;
  fqdn = if (cfg.subdomain != "") then "${cfg.subdomain}.${domain}" else domain;
  nginx = config.services.nginx;

  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in
{
  options.services.ftp-webserver = {
    enable = mkEnableOption "FTP webserver.";
    subdomain = mkOption {
      type = types.str;
      default = "ftp";
      description = "Subdomain for Nginx virtual host. Leave empty for root domain.";
    };
    forceSSL = mkOption {
      type = types.bool;
      default = true;
      description = "Force SSL for Nginx virtual host.";
    };
    root = mkOption {
      type = types.str;
      default = "/srv/www";
      description = "Root directory for the FTP webserver.";
    };
  };

  config = mkIf cfg.enable {
    services.nginx.virtualHosts."${fqdn}" = {
      root = cfg.root;
      locations."/" = {
        extraConfig = ''
          autoindex on;
          autoindex_exact_size off;
          autoindex_localtime on;
        '';
      };
      forceSSL = cfg.forceSSL;
      enableACME = cfg.forceSSL;
    };

    systemd.tmpfiles.rules = [ "d ${cfg.root} 0755 ${nginx.user} ${nginx.group}" ];
  };
}
