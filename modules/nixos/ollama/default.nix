{ config, lib, ... }:

let
  cfg = config.services.ollama;
  domain = config.networking.domain;
  fqdn = if (cfg.subdomain != "") then "${cfg.subdomain}.${domain}" else domain;

  inherit (lib)
    mkDefault
    mkForce
    mkIf
    mkOption
    types
    ;
in
{
  options.services.ollama = {
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

  config = mkIf cfg.enable {
    services.ollama = {
      user = mkDefault "ollama";
      group = mkDefault "ollama";
    };

    services.nginx.virtualHosts."${fqdn}" = {
      forceSSL = cfg.forceSSL;
      enableACME = cfg.forceSSL;
      locations."/" = {
        proxyPass = mkDefault "http://localhost:${toString cfg.port}";
        proxyWebsockets = mkDefault true;
        recommendedProxySettings = mkForce false;
        extraConfig = ''
          proxy_set_header Host localhost:${toString cfg.port};
        '';
      };
    };

    security.acme.certs."${fqdn}".postRun = mkIf cfg.forceSSL "systemctl restart ollama.service";

    systemd.tmpfiles.rules = [
      "d ${cfg.home} 0755 ${cfg.user} ${cfg.group} -"
    ];
  };
}
