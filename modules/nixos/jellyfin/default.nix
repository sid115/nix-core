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
    mkIf
    mkOption
    types
    ;

  inherit (lib.utils)
    mkReverseProxyOption
    mkVirtualHost
    ;
in
{
  options.services.jellyfin = {
    reverseProxy = mkReverseProxyOption "Jellyfin" "jf";
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

    services.nginx.virtualHosts = mkIf cfg.reverseProxy.enable {
      "${fqdn}" = mkVirtualHost {
        inherit config fqdn;
        port = 8096;
        ssl = cfg.reverseProxy.forceSSL;
      };
    };

    security.acme.certs = mkIf (with cfg.reverseProxy; enable && forceSSL) {
      "${fqdn}".postRun = "systemctl restart jellyfin.service";
    };
  };
}
