{ config, lib, ... }:

let
  cfg = config.services.jirafeau;
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
      nginxConfig = {
        enableACME = if cfg.reverseProxy.enable then cfg.reverseProxy.forceSSL else mkDefault false;
        forceSSL = if cfg.reverseProxy.enable then cfg.reverseProxy.forceSSL else mkDefault false;
        listenAddresses = mkDefault [ "0.0.0.0" ]; # FIXME: 127.0.0.1 does not work
        serverName = fqdn;
        sslCertificate =
          mkIf (with cfg.reverseProxy; enable && forceSSL)
            "${config.security.acme.certs."${fqdn}".directory}/cert.pem";
        sslCertificateKey =
          mkIf (with cfg.reverseProxy; enable && forceSSL)
            "${config.security.acme.certs."${fqdn}".directory}/key.pem";
      };
    };
  };
}
