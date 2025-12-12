{ config, lib, ... }:

let
  cfg = config.services.jirafeau;
  domain = config.networking.domain;
  subdomain = cfg.reverseProxy.subdomain;
  fqdn = if (subdomain != "") then "${subdomain}.${domain}" else domain;

  inherit (lib)
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in
{
  options.services.jirafeau = {
    reverseProxy = {
      enable = mkEnableOption "Nginx reverse proxy for Jirafeau";
      subdomain = mkOption {
        type = types.str;
        default = "share";
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
    services.jirafeau = {
      hostName = fqdn;
      extraConfig = mkDefault ''
        $cfg['style'] = 'dark-courgette';
        $cfg['maximal_upload_size'] = 4096;
      '';
      nginxConfig = mkIf cfg.reverseProxy.enable {
        enableACME = cfg.reverseProxy.forceSSL;
        forceSSL = cfg.reverseProxy.forceSSL;
        listenAddresses = [ "127.0.0.1" ];
        serverName = fqdn;
      };
    };
  };
}
