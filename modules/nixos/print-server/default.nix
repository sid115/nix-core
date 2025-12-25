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
  port = "631";

  inherit (lib)
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    types
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
    reverseProxy = {
      enable = mkEnableOption "Nginx reverse proxy for print-server";
      subdomain = mkOption {
        type = types.str;
        default = "print";
        description = "Subdomain for Nginx virtual host. Leave empty for root domain.";
      };
      forceSSL = mkOption {
        type = types.bool;
        default = true;
        description = "Force SSL for Nginx virtual host.";
      };
    };
  };

  config = mkIf cfg.enable {
    services.printing = {
      enable = true;
      listenAddresses = [ "*:${port}" ];
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

    services.nginx.virtualHosts.${fqdn} = mkIf cfg.reverseProxy.enable {
      forceSSL = cfg.reverseProxy.forceSSL;
      enableACME = cfg.reverseProxy.forceSSL;
      locations."/".proxyPass = mkDefault "http://127.0.0.1:${port}";
      sslCertificate = mkIf cfg.reverseProxy.forceSSL "${
        config.security.acme.certs."${fqdn}".directory
      }/cert.pem";
      sslCertificateKey = mkIf cfg.reverseProxy.forceSSL "${
        config.security.acme.certs."${fqdn}".directory
      }/key.pem";
    };
  };
}
