{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.print-server;
  domain = config.networking.domain;
  fqdn = if (isNotEmptyStr cfg.subdomain) then "${cfg.subdomain}.${domain}" else domain;

  inherit (lib)
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  isNotEmptyStr = (import ../../../lib).isNotEmptyStr; # FIXME: cannot get lib overlay to work
in
{
  options.services.print-server = {
    enable = mkEnableOption "Enable print server.";
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

  config = mkIf cfg.enable {
    services.printing = {
      enable = true;
      webInterface = true;
      tempDir = "/tmp/cups";
      allowFrom = [ "all" ];
      snmpConf = ''
        Address @LOCAL
      '';
      clientConf = '''';
      openFirewall = true;
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
      openFirewall = true;
    };

    services.nginx.virtualHosts.${fqdn} = {
      forceSSL = cfg.forceSSL;
      enableACME = cfg.forceSSL;
      locations."/".proxyPass = mkDefault "http://localhost:631";
    };
  };
}
