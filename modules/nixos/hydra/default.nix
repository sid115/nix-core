{ config, lib, ... }:

let
  cfg = config.services.hydra;
  domain = config.networking.domain;
  subdomain = cfg.reverseProxy.subdomain;
  fqdn = if (cfg.reverseProxy.enable && subdomain != "") then "${subdomain}.${domain}" else domain;
  mailserver = config.mailserver;

  inherit (lib)
    mkDefault
    mkIf
    ;

  inherit (lib.utils)
    mkReverseProxyOption
    mkUrl
    mkVirtualHost
    ;
in
{
  options.services.hydra = {
    reverseProxy = mkReverseProxyOption "Hydra" "hydra";
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

    services.nginx.virtualHosts."${cfg.hydraURL}" = mkIf cfg.reverseProxy.enable (mkVirtualHost {
      inherit config;
      fqdn = cfg.hydraURL;
      port = cfg.port;
      ssl = cfg.reverseProxy.forceSSL;
    });

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
