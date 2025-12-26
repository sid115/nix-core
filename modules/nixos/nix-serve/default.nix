{ config, lib, ... }:

let
  cfg = config.services.nix-serve;
  domain = config.networking.domain;
  subdomain = cfg.reverseProxy.subdomain;
  fqdn = if (cfg.reverseProxy.enable && subdomain != "") then "${subdomain}.${domain}" else domain;

  inherit (lib)
    mkDefault
    mkIf
    ;

  inherit (lib.utils)
    mkReverseProxyOption
    mkVirtualHost
    ;
in
{
  options.services.nix-serve = {
    reverseProxy = mkReverseProxyOption "nix-serve" "cache";
  };

  config = mkIf cfg.enable {
    services.nix-serve = {
      bindAddress = mkDefault (if cfg.reverseProxy.enable then "127.0.0.1" else "0.0.0.0");
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

    services.nginx.virtualHosts = mkIf cfg.reverseProxy.enable {
      "${fqdn}" = mkVirtualHost {
        inherit config fqdn;
        port = cfg.port;
        ssl = cfg.reverseProxy.forceSSL;
      };
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
