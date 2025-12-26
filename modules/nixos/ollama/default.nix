{ config, lib, ... }:

let
  cfg = config.services.ollama;
  domain = config.networking.domain;
  subdomain = cfg.reverseProxy.subdomain;
  fqdn = if (cfg.reverseProxy.enable && subdomain != "") then "${subdomain}.${domain}" else domain;

  inherit (lib)
    mkDefault
    mkForce
    mkIf
    ;

  inherit (lib.utils)
    mkReverseProxyOption
    mkVirtualHost
    ;
in
{
  options.services.ollama = {
    reverseProxy = mkReverseProxyOption "Ollama" "ollama";
  };

  config = mkIf cfg.enable {
    services.ollama = {
      host = mkDefault (if cfg.reverseProxy.enable then "127.0.0.1" else "0.0.0.0");
      user = mkDefault "ollama";
      group = mkDefault "ollama";
    };

    services.nginx.virtualHosts = mkIf cfg.reverseProxy.enable {
      "${fqdn}" =
        let
          extraConfig = ''
            proxy_set_header Host ${cfg.host}:${toString cfg.port};
          '';
        in
        mkVirtualHost {
          inherit config fqdn extraConfig;
          port = cfg.port;
          ssl = cfg.reverseProxy.forceSSL;
          proxyWebsockets = true;
          recommendedProxySettings = mkForce false;
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
