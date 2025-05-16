{ config, lib, ... }:

let
  cfg = config.services.jirafeau;
  domain = config.networking.domain;
  fqdn = if (isNotEmptyStr cfg.subdomain) then "${cfg.subdomain}.${domain}" else domain;

  inherit (lib)
    isNotEmptyStr
    mkDefault
    mkOption
    types
    ;
in
{
  options.services.jirafeau = {
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

  config = {
    services.jirafeau = {
      hostName = fqdn;
      extraConfig = mkDefault ''
        $cfg['style'] = 'dark-courgette';
        $cfg['maximal_upload_size'] = 4096;
      '';
      nginxConfig = {
        enableACME = cfg.forceSSL;
        forceSSL = cfg.forceSSL;
        serverName = cfg.hostName;
      };
    };
  };
}
