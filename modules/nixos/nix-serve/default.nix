{ config, lib, ... }:

let
  cfg = config.services.nix-serve;
  domain = config.networking.domain;
  subdomain = cfg.reverseProxy.subdomain;
  fqdn = if (subdomain != "") then "${subdomain}.${domain}" else domain;

  inherit (lib)
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in
{
  options.services.nix-serve = {
    reverseProxy = {
      enable = mkEnableOption "Nginx reverse proxy for nix-serve";
      subdomain = mkOption {
        type = types.str;
        default = "rss";
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
    services.nix-serve = {
      bindAddress = mkDefault "0.0.0.0";
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

    services.nginx.virtualHosts."${fqdn}" = mkIf cfg.reverseProxy.enable {
      enableACME = cfg.reverseProxy.forceSSL;
      forceSSL = cfg.reverseProxy.forceSSL;
      locations."/".proxyPass = mkDefault "http://127.0.0.1:${toString cfg.port}";
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
