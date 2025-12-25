{ config, lib, ... }:

let
  cfg = config.services.webPage;
  domain = config.networking.domain;
  fqdn = if (cfg.subdomain != "") then "${cfg.subdomain}.${domain}" else domain;
  nginxUser = config.services.nginx.user;

  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in
{
  options.services.webPage = {
    enable = mkEnableOption "static web page hosting";
    subdomain = mkOption {
      type = types.str;
      default = "www";
      description = "The subdomain to serve the web page on. Leave empty for root domain.";
    };
    forceSSL = mkOption {
      type = types.bool;
      default = true;
      description = "Force SSL for Nginx virtual host.";
    };
    webRoot = mkOption {
      type = types.str;
      description = "The root directory of the web page.";
      example = "/var/www";
    };
    test = mkOption {
      type = types.bool;
      default = false;
      description = "If true, a sample index.html will be placed in the web root for testing purposes.";
    };
  };

  config = mkIf cfg.enable {
    services.nginx.virtualHosts."${fqdn}" = {
      enableACME = cfg.forceSSL;
      forceSSL = cfg.forceSSL;
      root = cfg.webRoot;
      locations."/".index = "index.html";
      sslCertificate = mkIf cfg.forceSSL "${config.security.acme.certs."${fqdn}".directory}/cert.pem";
      sslCertificateKey = mkIf cfg.forceSSL "${config.security.acme.certs."${fqdn}".directory}/key.pem";
    };

    systemd.tmpfiles.rules = [ "d ${cfg.webRoot} 0755 ${nginxUser} ${nginxUser} -" ];

    system.activationScripts.webPagePermissions = ''
      chown -R ${nginxUser}:${nginxUser} ${cfg.webRoot}
      chmod -R 0755 ${cfg.webRoot}
    '';

    # test page
    environment.etc."sample.html" = mkIf cfg.test { source = ./sample.html; };
    system.activationScripts.moveSampleHtmlToWebRoot = mkIf cfg.test ''
      mv /etc/sample.html ${cfg.webRoot}/index.html
      chown -R ${nginxUser}:${nginxUser} ${cfg.webRoot}
      chmod -R 0755 ${cfg.webRoot}
    '';
  };
}
