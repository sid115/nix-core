{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.grafana;
  domain = config.networking.domain;
  fqdn = if (isNotEmptyStr cfg.subdomain) then "${cfg.subdomain}.${domain}" else domain;

  inherit (lib)
    mkDefault
    mkIf
    mkOption
    types
    ;

  isNotEmptyStr = (import ../../../lib).isNotEmptyStr; # FIXME: cannot get lib overlay to work
in
{
  imports = [
    ./prometheus
  ];

  options.services.grafana = {
    subdomain = mkOption {
      type = types.str;
      default = "grafana";
      description = "Subdomain for Nginx virtual host. Leave empty for root domain.";
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
          root_url = if cfg.forceSSL then "https://${fqdn}/" else "http://${fqdn}";
        };
        security = {
          disable_initial_admin_creation = mkDefault true;
        };
      };

      provision = {
        dashboards = import ./dashboards;
        datasources = import ./datasources.nix { inherit config lib pkgs; };
      };
    };

    services.nginx.virtualHosts."${fqdn}" = {
      forceSSL = cfg.forceSSL;
      enableACME = cfg.forceSSL;
      locations."/" = {
        proxyPass = mkDefault (with cfg.settings.server; "http://${http_addr}:${toString http_port}");
        proxyWebsockets = mkDefault true;
        recommendedProxySettings = mkDefault true;
      };
    };
  };
}
