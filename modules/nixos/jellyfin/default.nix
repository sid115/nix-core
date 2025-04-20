{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.jellyfin;
  fqdn = "${cfg.subdomain}.${config.networking.domain}";

  inherit (lib)
    mkDefault
    mkIf
    mkOption
    types
    ;
in
{
  options.services.jellyfin = {
    subdomain = mkOption {
      type = types.str;
      default = "jf";
      description = "Subdomain for Nginx virtual host.";
    };
    forceSSL = mkOption {
      type = types.bool;
      default = true;
      description = "Force SSL for Nginx virtual host.";
    };
    libraries = mkOption {
      type = types.listOf types.str;
      default = [
        "movies"
        "music"
        "shows"
      ];
      description = "A list of library names. Directories for these will be created under ${cfg.dataDir}/libraries.";
    };
  };

  config = mkIf cfg.enable {
    services.jellyfin = {
      openFirewall = mkDefault false;
    };

    environment.systemPackages = with pkgs; [
      jellyfin-web
      jellyfin-ffmpeg
    ];

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0770 ${cfg.user} ${cfg.group} -"
      "z ${cfg.dataDir} 0770 ${cfg.user} ${cfg.group} -"
    ];

    services.nginx.virtualHosts."${fqdn}" = {
      forceSSL = cfg.forceSSL;
      enableACME = cfg.forceSSL;
      locations."/".proxyPass = "http://localhost:8096";
    };

    security.acme.certs."${fqdn}".postRun = mkIf cfg.forceSSL "systemctl restart jellyfin.service";
  };
}
