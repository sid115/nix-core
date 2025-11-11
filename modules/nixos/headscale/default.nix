# todo siqtch to posthres, sll optinal, etc

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.headscale;
  inherit (lib)
    mkIf
    mkOption
    mkDefault
    types
    ;
  domain = config.networking.domain;
  fqdn = if cfg.subdomain == "" then domain else "${cfg.subdomain}.${domain}";

in
{
  options.services.headscale = {
    subdomain = mkOption {
      type = types.str;
      default = "headscale";
      description = "Subdomain for the Headscale service. Combined with networking.domain.";
    };
    internalPort = mkOption {
      type = types.port;
      default = 8077;
      description = "The internal port Headscale listens on for the reverse proxy.";
    };
    enableDerpServer = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable the self-hosted DERP relay server.";
    };
    baseDomain = mkOption {
      type = types.str;
      default = "headscale.local";
      description = "The base domain used for MagicDNS.";
    };
    openFirewall = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to automatically open firewall ports (80, 443, 3478).";
    };

    overrideLocalDns = mkOption {
      type = types.bool;
      default = false;
      description = "If true, Headscale overrides all DNS settings on clients. Requires globalNameservers.";
    };
    globalNameservers = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "List of global DNS servers to use when overrideLocalDns is true. E.g., [ \"1.1.1.1\" ].";
    };
  };

  config = mkIf cfg.enable {
    services.headscale = {
      address = "127.0.0.1";
      port = cfg.internalPort;
      settings = {
        database.type = mkDefault "sqlite";
        server_url = "https://" + fqdn;
        derp.server.enable = cfg.enableDerpServer;
        dns = {
          magic_dns = mkDefault true;
          base_domain = cfg.baseDomain;
          override_local_dns = cfg.overrideLocalDns;
          nameservers.global = cfg.globalNameservers;
        };
      };
    };

    services.nginx.virtualHosts.${fqdn} = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.internalPort}";
        proxyWebsockets = true;
      };
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [
        80
        443
      ];
      allowedUDPPorts = if cfg.enableDerpServer then [ 3478 ] else [ ];
    };
  };
}
