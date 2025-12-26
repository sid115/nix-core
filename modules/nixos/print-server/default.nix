{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.print-server;
  domain = config.networking.domain;
  subdomain = cfg.reverseProxy.subdomain;
  fqdn = if (cfg.reverseProxy.enable && subdomain != "") then "${subdomain}.${domain}" else domain;
  port = 631;

  inherit (lib)
    mkEnableOption
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
  options.services.print-server = {
    enable = mkEnableOption "print server";
    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Open firewall for printing and avahi service.";
    };
    reverseProxy = mkReverseProxyOption "print-server" "print";
  };

  config = mkIf cfg.enable {
    services.printing = {
      enable = true;
      listenAddresses = [ "*:${builtins.toString port}" ];
      webInterface = true;
      tempDir = "/tmp/cups";
      allowFrom = [ "all" ];
      snmpConf = ''
        Address @LOCAL
      '';
      clientConf = '''';
      openFirewall = cfg.openFirewall;
      drivers = with pkgs; [
        brlaser
        brgenml1lpr
        brgenml1cupswrapper # Brother
        postscript-lexmark # Lexmark
        hplip
        hplipWithPlugin # HP
        splix
        samsung-unified-linux-driver # Samsung
        gutenprint
        gutenprintBin # different vendors
      ];
      defaultShared = true;
      browsing = true;
      browsedConf = ''
        BrowsePoll ${fqdn}
      '';
    };

    # autodiscovery of network printers
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = cfg.openFirewall;
    };

    services.nginx.virtualHosts = mkIf cfg.reverseProxy.enable {
      ${fqdn} = mkVirtualHost {
        inherit config fqdn port;
        ssl = cfg.reverseProxy.forceSSL;
      };
    };
  };
}
