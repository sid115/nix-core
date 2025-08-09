{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.flask-hello;
  domain = config.networking.domain;
  fqdn = if (cfg.nginx.subdomain != "") then "${cfg.nginx.subdomain}.${domain}" else domain;

  inherit (lib)
    getExe
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    types
    ;
in
{
  options.services.flask-hello = {
    enable = mkEnableOption "Flask Hello World service.";

    package = mkPackageOption pkgs "flask-hello" { };

    port = mkOption {
      type = types.port;
      default = 5000;
      description = "Port for the Flask server to listen on.";
    };

    user = mkOption {
      type = types.str;
      description = "The user the Flask service will run as.";
      default = "flaskapp";
    };

    group = mkOption {
      type = types.str;
      description = "The group the Flask service will run as.";
      default = "flaskapp";
    };

    nginx = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Nginx as a reverse proxy for the Flask application.";
      };
      subdomain = mkOption {
        type = types.str;
        default = "flask-hello";
        description = "Subdomain for the Nginx virtual host. Leave empty for root domain.";
      };
      ssl = mkOption {
        type = types.bool;
        default = true;
        description = "Enable SSL for the Nginx virtual host using ACME.";
      };
    };
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [ inputs.flask-hello.overlays.default ];

    networking.firewall.allowedTCPPorts = [
      80 # ACME challenge
      443
    ];

    systemd.services.flask-hello = {
      description = "Flask Hello World";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${getExe cfg.package}";
        Restart = "on-failure";
        User = cfg.user;
        Group = cfg.group;
      };
    };

    users.users."${cfg.user}" = {
      isSystem = true;
      group = cfg.group;
    };
    users.groups."${cfg.group}" = { };

    services.nginx = mkIf cfg.nginx.enable {
      enable = mkDefault true;
      virtualHosts."${fqdn}" = {
        enableACME = cfg.nginx.ssl;
        forceSSL = cfg.nginx.ssl;
        locations."/".proxyPass = "http://127.0.0.1:${toString cfg.port}";
      };
    };

    security.acme = mkIf (cfg.nginx.enable && cfg.nginx.ssl) {
      acceptTerms = true;
      defaults.email = mkDefault "postmaster@${domain}";
      defaults.webroot = mkDefault "/var/lib/acme/acme-challenge";
      certs."${domain}".postRun = "systemctl reload nginx.service";
    };
  };
}
