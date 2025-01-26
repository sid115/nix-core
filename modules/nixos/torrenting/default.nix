{ config, lib, ... }:

let
  _deluge = config.services.deluge;
  cfg = config.services.torrenting;
  fqdn = "${cfg.subdomain}.${config.networking.domain}";

  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in
{
  options.services.torrenting = {
    enable = mkEnableOption "Enable torrenting via deluge and deluge-web.";
    subdomain = mkOption {
      type = types.str;
      default = "torrent";
      description = "Subdomain for the Nginx proxy.";
    };
    forceSSL = mkOption {
      type = types.bool;
      default = true;
      description = "Force SSL for Nginx virtual host.";
    };
  };

  config = mkIf cfg.enable {
    services.deluge = {
      enable = true;
      web.enable = true;
      openFirewall = true;
      declarative = true;
      config = {
        download_location = "/srv/torrents/";
        max_upload_speed = "1000.0";
        share_ratio_limit = "2.0";
        allow_remote = true;
        daemon_port = 58846;
        listen_ports = [
          6881
          6889
        ];
      };
      authFile = "/run/secrets/deluge/auth";
    };

    systemd.tmpfiles.rules = [
      "d ${_deluge.config.download_location} 0755 ${_deluge.user} ${_deluge.group}"
    ];

    services.nginx.virtualHosts."${fqdn}" = {
      enableACME = cfg.forceSSL;
      forceSSL = cfg.forceSSL;
      locations."/".proxyPass = "http://localhost:${toString _deluge.web.port}";
    };

    sops.secrets."deluge/auth" = {
      owner = _deluge.user;
      group = _deluge.group;
      mode = "0440";
    };
  };
}
