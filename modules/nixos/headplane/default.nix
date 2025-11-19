{
  inputs,
  config,
  lib,
  ...
}:

let
  cfg = config.services.headplane;
  domain = config.networking.domain;
  fqdn = if (cfg.subdomain != "") then "${cfg.subdomain}.${domain}" else domain;
  headscale = config.services.headscale;

  inherit (lib)
    mkDefault
    mkIf
    mkOption
    types
    ;
in
{
  options.services.headplane = {
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

  config = mkIf cfg.enable {
    imports = [ inputs.headplane.nixosModules.headplane ];

    nixpkgs.overlays = [
      inputs.headplane.overlays.default
    ];

    services.headplane = {
      settings = {
        server = {
          host = mkDefault "127.0.0.1";
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

    services.nginx.virtualHosts."${fqdn}" = {
      forceSSL = cfg.forceSSL;
      enableACME = cfg.forceSSL;
      locations."/" = {
        proxyPass = with cfg.settings.server; "http://${host}:${toString port}";
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
