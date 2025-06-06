{ config, lib, ... }:

let
  cfg = config.services.hydra;
  domain = config.networking.domain;
  fqdn = if (cfg.subdomain != "") then "${cfg.subdomain}.${domain}" else domain;
  mailserver = config.mailserver;

  inherit (lib)
    mkDefault
    mkIf
    mkOption
    types
    ;
in
{
  options.services.hydra = {
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

  config = mkIf cfg.enable {
    services.hydra = {
      port = mkDefault 3344;
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

    services.nginx.virtualHosts."${cfg.hydraURL}" = {
      enableACME = cfg.forceSSL;
      forceSSL = cfg.forceSSL;
      locations."/".proxyPass = "http://localhost:${toString cfg.port}";
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
