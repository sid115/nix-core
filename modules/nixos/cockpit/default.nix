{
  config,
  lib,
  ...
}:

let
  cfg = config.services.cockpit;
  domain = config.networking.domain;
  fqdn = if (cfg.subdomain != "") then "${cfg.subdomain}.${domain}" else domain;

  inherit (lib)
    mkDefault
    mkIf
    mkOption
    types
    ;
in
{
  options.services.cockpit = {
    subdomain = mkOption {
      type = types.str;
      default = "cock";
      description = "Subdomain for Nginx virtual host. Leave empty for root domain.";
    };
    forceSSL = mkOption {
      type = types.bool;
      default = true;
      description = "Force SSL for Nginx virtual host.";
    };
  };

  config = mkIf cfg.enable {
    services.cockpit = {
      port = mkDefault 9090;
      settings = {
        WebService = {
          AllowUnencrypted = mkDefault true;
          ProtocolHeader = mkDefault "X-Forwarded-Proto";
        };
        Log = {
          Fatal = mkDefault "criticals warnings";
        };
      };
      allowed-origins = [
        "http://localhost:${toString cfg.port}"
        "http://${fqdn}"
        "https://${fqdn}"
        "wss://${fqdn}"
      ];
    };

    # https://github.com/NixOS/nixpkgs/issues/179676
    # services.pcp.enable = true;

    services.nginx.virtualHosts = {
      "${fqdn}" = {
        enableACME = cfg.forceSSL;
        forceSSL = cfg.forceSSL;
        locations."/" = {
          proxyPass = mkDefault "http://localhost:${toString cfg.port}";
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-Proto $scheme;

            # Required for web sockets to function
            proxy_http_version 1.1;
            proxy_buffering off;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";

            # Pass ETag header from Cockpit to clients.
            # See: https://github.com/cockpit-project/cockpit/issues/5239
            gzip off;
          '';
        };
      };
    };
  };
}
