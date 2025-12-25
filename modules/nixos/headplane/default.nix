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
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in
{
  imports = [ inputs.headplane.nixosModules.headplane ];

  options.services.headplane = {
    reverseProxy = {
      enable = mkEnableOption "Nginx reverse proxy for headplane";
      subdomain = mkOption {
        type = types.str;
        default = "headplane";
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

    services.nginx.virtualHosts."${fqdn}" = mkIf cfg.reverseProxy.enable {
      forceSSL = cfg.reverseProxy.forceSSL;
      enableACME = cfg.reverseProxy.forceSSL;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.settings.server.port}";
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
