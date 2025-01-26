{ config, lib, ... }:

let
  cfg = config.services.webPage;
  fqdn = "${cfg.subdomain}.${config.networking.domain}";
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
    enable = mkEnableOption "Whether to enable the web page service.";
    subdomain = mkOption {
      type = types.str;
      default = "www";
      description = "The subdomain to serve the web page on.";
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
