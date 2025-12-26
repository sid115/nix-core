{
  config,
  lib,
  ...
}:

let
  cfg = config.services.headscale;
  domain = config.networking.domain;
  subdomain = cfg.reverseProxy.subdomain;
  fqdn = if (cfg.reverseProxy.enable && subdomain != "") then "${subdomain}.${domain}" else domain;
  acl = "headscale/acl.hujson";

  inherit (lib)
    mkDefault
    mkIf
    mkOption
    optional
    optionals
    types
    ;

  inherit (lib.utils)
    mkReverseProxyOption
    mkUrl
    mkVirtualHost
    ;
in
{
  options.services.headscale = {
    reverseProxy = mkReverseProxyOption "Headscale" "headscale";
    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to automatically open firewall ports. TCP: 80, 443; UDP: 3478.";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !cfg.settings.derp.server.enable || cfg.reverseProxy.forceSSL;
        message = "nix-core/nixos/headscale: DERP requires TLS";
      }
      {
        assertion = fqdn != cfg.settings.dns.base_domain;
        message = "nix-core/nixos/headscale: `settings.server_url` must be different from `settings.dns.base_domain`";
      }
      {
        assertion = !cfg.settings.dns.override_local_dns || cfg.settings.dns.nameservers.global != [ ];
        message = "nix-core/nixos/headscale: `settings.dns.nameservers.global` must be set when `settings.dns.override_local_dns` is true";
      }
    ];

    environment.etc.${acl} = {
      inherit (config.services.headscale) user group;
      source = ./acl.hujson;
    };

    environment.shellAliases = {
      hs = "${cfg.package}/bin/headscale";
    };

    services.headscale = {
      address = mkDefault (if cfg.reverseProxy.enable then "127.0.0.1" else "0.0.0.0");
      port = mkDefault 8077;
      settings = {
        policy.path = "/etc/${acl}";
        database.type = "sqlite"; # postgres is highly discouraged as it is only supported for legacy reasons
        server_url = mkUrl {
          inherit fqdn;
          ssl = with cfg.reverseProxy; enable && forceSSL;
        };
        derp.server.enable = cfg.reverseProxy.forceSSL;
        dns = {
          magic_dns = mkDefault true;
          base_domain = mkDefault "headscale.internal";
          override_local_dns = mkDefault true;
          nameservers.global = optionals cfg.settings.dns.override_local_dns [
            "1.1.1.1"
            "1.0.0.1"
            "2606:4700:4700::1111"
            "2606:4700:4700::1001"
          ];
        };
      };
    };

    services.nginx.virtualHosts = mkIf cfg.reverseProxy.enable {
      "${fqdn}" = mkVirtualHost {
        inherit config fqdn;
        port = cfg.port;
        ssl = cfg.reverseProxy.forceSSL;
        proxyWebsockets = true;
      };
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [
        80
        443
      ];
      allowedUDPPorts = optional cfg.settings.derp.server.enable 3478;
    };
  };
}
