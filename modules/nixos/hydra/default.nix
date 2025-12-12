{ config, lib, ... }:

let
  cfg = config.services.hydra;
  domain = config.networking.domain;
  subdomain = cfg.reverseProxy.subdomain;
  fqdn = if (subdomain != "") then "${subdomain}.${domain}" else domain;
  mailserver = config.mailserver;

  inherit (lib)
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in
{
  options.services.hydra = {
    reverseProxy = {
      enable = mkEnableOption "Nginx reverse proxy for hydra";
      subdomain = mkOption {
        type = types.str;
        default = "hydra";
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
    services.hydra = {
      port = mkDefault 3344;
      listenHost = mkDefault (if cfg.reverseProxy.enable then "127.0.0.1" else "0.0.0.0");
      hydraURL = fqdn;
      useSubstitutes = mkDefault true;

      notificationSender = mkDefault "hydra@${config.networking.domain}";
      smtpHost = mkDefault mailserver.fqdn;
    };

    nix.settings.allowed-uris = [
      "github:"
      "git+https://github.com/"
      "git+ssh://github.com/"
    ];

    services.nginx.virtualHosts."${cfg.hydraURL}" = mkIf cfg.reverseProxy.enable {
      enableACME = cfg.reverseProxy.forceSSL;
      forceSSL = cfg.reverseProxy.forceSSL;
      locations."/".proxyPass = mkDefault "http://127.0.0.1:${toString cfg.port}";
    };

    mailserver.loginAccounts = mkIf mailserver.enable {
      "${cfg.notificationSender}" = {
        hashedPasswordFile = config.sops.secrets."hydra/hashed-smtp-password".path;
      };
    };

    sops =
      let
        owner = "hydra";
        group = "hydra";
        mode = "0440";
      in
      {
        secrets."hydra/smtp-password" = {
          inherit owner group mode;
        };
        secrets."hydra/hashed-smtp-password" = mkIf mailserver.enable {
          inherit owner group mode;
        };
      };
  };
}
