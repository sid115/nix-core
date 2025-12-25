{ config, lib, ... }:

let
  cfg = config.services.ollama;
  domain = config.networking.domain;
  subdomain = cfg.reverseProxy.subdomain;
  fqdn = if (cfg.reverseProxy.enable && subdomain != "") then "${subdomain}.${domain}" else domain;

  inherit (lib)
    mkDefault
    mkEnableOption
    mkForce
    mkIf
    mkOption
    types
    ;
in
{
  options.services.ollama = {
    reverseProxy = {
      enable = mkEnableOption "Nginx reverse proxy for ollama";
      subdomain = mkOption {
        type = types.str;
        default = "ollama";
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
    services.ollama = {
      host = mkDefault (if cfg.reverseProxy.enable then "127.0.0.1" else "0.0.0.0");
      user = mkDefault "ollama";
      group = mkDefault "ollama";
    };

    services.nginx.virtualHosts."${fqdn}" = mkIf cfg.reverseProxy.enable {
      forceSSL = cfg.reverseProxy.forceSSL;
      enableACME = cfg.reverseProxy.forceSSL;
      locations."/" = {
        proxyPass = mkDefault "http://127.0.0.1:${toString cfg.port}";
        proxyWebsockets = mkDefault true;
        recommendedProxySettings = mkForce false;
        extraConfig = ''
          proxy_set_header Host ${cfg.host}:${toString cfg.port};
        '';
      };
    };

    security.acme.certs = mkIf (with cfg.reverseProxy; enable && forceSSL) {
      "${fqdn}".postRun = "systemctl restart ollama.service";
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.home} 0755 ${cfg.user} ${cfg.group} -"
    ];
  };
}
