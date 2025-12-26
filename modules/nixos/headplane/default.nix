{
  inputs,
  config,
  lib,
  ...
}:

let
  cfg = config.services.headplane;
  domain = config.networking.domain;
  subdomain = cfg.reverseProxy.subdomain;
  fqdn = if (cfg.reverseProxy.enable && subdomain != "") then "${subdomain}.${domain}" else domain;
  headscale = config.services.headscale;

  inherit (lib)
    mkDefault
    mkIf
    recursiveUpdate
    ;

  inherit (lib.utils)
    mkReverseProxyOption
    mkVirtualHost
    ;
in
{
  imports = [ inputs.headplane.nixosModules.headplane ];

  options.services.headplane = {
    reverseProxy = mkReverseProxyOption "Headplane" "headplane";
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [
      inputs.headplane.overlays.default
    ];

    services.headplane = {
      settings = {
        server = {
          host = mkDefault (if cfg.reverseProxy.enable then "127.0.0.1" else "0.0.0.0");
          port = mkDefault 3000;
          cookie_secret_path = config.sops.secrets."headplane/cookie_secret".path;
        };
        headscale = {
          url = "http://127.0.0.1:${toString headscale.port}";
          public_url = headscale.settings.server_url;
          config_path = "/etc/headscale/config.yaml";
        };
        integration.agent = {
          enabled = mkDefault true;
          pre_authkey_path = config.sops.secrets."headplane/agent_pre_authkey".path;
        };
      };
    };

    services.nginx.virtualHosts = mkIf cfg.reverseProxy.enable {
      "${fqdn}" = mkVirtualHost {
        inherit config fqdn;
        port = cfg.settings.server.port;
        ssl = cfg.reverseProxy.forceSSL;
        proxyWebsockets = true;
      };
    };

    sops.secrets =
      let
        owner = headscale.user;
        group = headscale.group;
        mode = "0400";
      in
      {
        "headplane/cookie_secret" = {
          inherit owner group mode;
        };
        "headplane/agent_pre_authkey" = {
          inherit owner group mode;
        };
      };
  };
}
