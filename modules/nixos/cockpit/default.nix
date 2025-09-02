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
        };
        Log = {
          Fatal = mkDefault "criticals warnings";
        };
      };
      allowed-origins = [
        "http://localhost:${toString cfg.port}"
      ];
    };

    # https://github.com/NixOS/nixpkgs/issues/179676
    # services.pcp.enable = true;

    services.nginx.virtualHosts = {
      "${fqdn}" = {
        enableACME = cfg.forceSSL;
        forceSSL = cfg.forceSSL;
        locations."/".proxyPass = mkDefault "http://localhost:${toString cfg.port}";
      };
    };
  };
}
