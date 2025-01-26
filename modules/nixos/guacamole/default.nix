{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.guacamole;
  fqdn = "${cfg.subdomain}.${config.networking.domain}";

  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in
{

  options.services.guacamole = {
    enable = mkEnableOption "Whether to enable Guacamole server and client.";
    subdomain = mkOption {
      type = types.str;
      default = "guac";
      description = "Subdomain for Nginx virtual host.";
    };
    forceSSL = mkOption {
      type = types.bool;
      default = true;
      description = "Force SSL for Nginx virtual host.";
    };
    settings = mkOption {
      type = types.attrs;
      default = {
        guacd-hostname = "localhost";
        guacd-port = 4822;
        guacd-ssl = true;
      };
      description = "config.services.guacamole-client.settings";
    };
    users = mkOption {
      type = types.nullOr types.path;
      default = null;
      example = "./path/to/user-mapping.xml";
      description = ''
        Configuration file that corresponds to `user-mapping.xml`.
      '';
    };
  };

  config = mkIf cfg.enable {
    services.guacamole-server = {
      enable = true;
      package = pkgs.guacamole-server;
      userMappingXml = cfg.users;
      logbackXml = ./logback.xml;
    };

    services.guacamole-client = {
      enable = true;
      package = pkgs.guacamole-client;
      settings = cfg.settings;
    };

    services.tomcat = {
      enable = true;
      baseDir = "/var/lib/tomcat";
      purifyOnStart = true;
      webapps = [ config.services.guacamole-client.package ];
      package = pkgs.tomcat9;
    };

    services.nginx.virtualHosts = {
      "${fqdn}" = {
        enableACME = cfg.forceSSL;
        forceSSL = cfg.forceSSL;
        locations."/".proxyPass = "http://localhost:8080/guacamole/";
      };
      "sample.${config.networking.domain}" = {
        enableACME = cfg.forceSSL;
        forceSSL = cfg.forceSSL;
        locations."/".proxyPass = "http://localhost:8080/sample/";
      };
    };
  };
}
