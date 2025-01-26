{ config, lib, ... }:

let
  cfg = config.services.ftp-webserver;
  fqdn = "${cfg.subdomain}.${config.networking.domain}";
  _nginx = config.services.nginx;

  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;
in
{
  options.services.ftp-webserver = {
    enable = mkEnableOption "Whether to enable the FTP webserver.";
    subdomain = mkOption {
      type = types.str;
      default = "ftp";
      description = "Subdomain for the FTP webserver.";
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

    systemd.tmpfiles.rules = [ "d ${cfg.root} 0755 ${_nginx.user} ${_nginx.group}" ];
  };
}
