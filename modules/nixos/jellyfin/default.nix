{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.jellyfin;
  domain = config.networking.domain;
  subdomain = cfg.reverseProxy.subdomain;
  fqdn = if (cfg.reverseProxy.enable && subdomain != "") then "${subdomain}.${domain}" else domain;

  inherit (lib)
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in
{
  options.services.jellyfin = {
    reverseProxy = {
      enable = mkEnableOption "Nginx reverse proxy for Jellyfin";
      subdomain = mkOption {
        type = types.str;
        default = "jf";
        description = "Subdomain for Nginx virtual host. Leave empty for root domain.";
      };
      forceSSL = mkOption {
        type = types.bool;
        default = true;
        description = "Force SSL for Nginx virtual host.";
      };
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

    systemd.tmpfiles.rules =
      (map (
        library: "d ${cfg.dataDir}/libraries/${library} 0770 ${cfg.user} ${cfg.group} -"
      ) cfg.libraries)
      ++ [
        "z ${cfg.dataDir} 0770 ${cfg.user} ${cfg.group} -"
        "Z ${cfg.dataDir}/libraries 0770 ${cfg.user} ${cfg.group} -"
      ];

    services.nginx.virtualHosts."${fqdn}" = mkIf cfg.reverseProxy.enable {
      forceSSL = cfg.reverseProxy.forceSSL;
      enableACME = cfg.reverseProxy.forceSSL;
      locations."/".proxyPass = mkDefault "http://127.0.0.1:8096";
    };

    security.acme.certs = mkIf (with cfg.reverseProxy; enable && forceSSL) {
      "${fqdn}".postRun = "systemctl restart jellyfin.service";
    };
  };
}
