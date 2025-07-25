{ config, lib, ... }:

let
  cfg = config.services.nix-serve;
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
  options.services.nix-serve = {
    subdomain = mkOption {
      type = types.str;
      default = "cache";
      description = "Subdomain for Nginx virtual host. Leave empty for root domain.";
    };
    forceSSL = mkOption {
      type = types.bool;
      default = true;
      description = "Force SSL for Nginx virtual host.";
    };
  };

  config = mkIf cfg.enable {
    services.nix-serve = {
      port = mkDefault 5005;
      secretKeyFile = config.sops.templates."nix-serve/cache-priv-key".path;
    };

    users = {
      groups.nix-serve = { };
      users.nix-serve = {
        group = "nix-serve";
        home = "/var/nix-serve";
        createHome = true;
        isSystemUser = true;
      };
    };

    services.nginx.virtualHosts."${fqdn}" = {
      enableACME = cfg.forceSSL;
      forceSSL = cfg.forceSSL;
      locations."/".proxyPass = "http://${cfg.bindAddress}:${toString cfg.port}";
    };

    sops =
      let
        owner = "nix-serve";
        group = "nix-serve";
        mode = "0600";
      in
      {
        secrets."nix-serve/cache-priv-key" = {
          inherit owner group mode;
        };
        templates."nix-serve/cache-priv-key" = {
          inherit owner group mode;
          content = ''
            ${fqdn}:${config.sops.placeholder."nix-serve/cache-priv-key"}==
          '';
        };
      };
  };
}
