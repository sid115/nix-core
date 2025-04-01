{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.grafana;
  fqdn = "${cfg.subdomain}.${config.networking.domain}";

  inherit (lib)
    mkDefault
    mkIf
    mkOption
    types
    ;
in
{
  imports = [
    ./prometheus
  ];

  options.services.grafana = {
    subdomain = mkOption {
      type = types.str;
      default = "grafana";
      description = "Subdomain for the Nginx virtual host.";
    };
    forceSSL = mkOption {
      type = types.bool;
      default = true;
      description = "Force SSL for Nginx virtual host.";
    };
  };

  config = mkIf cfg.enable {
    services.grafana = {
      dataDir = mkDefault "/var/lib/grafana";
      settings = {
        server = {
          http_addr = mkDefault "127.0.0.1";
          http_port = mkDefault 3142;
          serve_from_sub_path = mkDefault false;
          root_url = "https://${fqdn}/";
        };
        security = {
          disable_initial_admin_creation = mkDefault true;
        };
      };

      provision = {
        dashboards = import ./dashboards.nix;
        datasources = import ./datasources.nix { inherit config lib pkgs; };
      };
    };

    services.nginx.virtualHosts."${fqdn}" = {
      forceSSL = cfg.forceSSL;
      enableACME = cfg.forceSSL;
      locations."/" = {
        proxyPass = with cfg.settings.server; "http://${http_addr}:${toString http_port}";
        proxyWebsockets = mkDefault true;
        recommendedProxySettings = mkDefault true;
      };
    };
  };
}
