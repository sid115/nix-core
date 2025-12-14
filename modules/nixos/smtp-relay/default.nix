{ config, lib, ... }:

let
  cfg = config.services.smtp-relay;
  domain = config.networking.domain;
  fqdn = "${cfg.subdomain}.${domain}";

  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in
{
  options.services.smtp-relay = {
    enable = mkEnableOption "SMTP relay server";
    subdomain = mkOption {
      type = types.str;
      default = "mail";
      description = "Subdomain for the SMTP relay server";
    };
    mailserverIP = mkOption {
      type = types.str;
      description = "IP address of the mail server";
      example = "100.64.0.1";
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [
      25
      465
      587
    ];

    security.acme.certs."${fqdn}" = {
      group = "postfix";
    };

    services.postfix = {
      enable = true;

      transport = ''
        ${domain} smtp:${cfg.mailserverIP}
      '';

      settings.main = {
        myhostname = fqdn;
        mydomain = domain;
        mydestination = [ "localhost" ];
        relay_domains = [ domain ];
        mynetworks = [
          "127.0.0.0/8"
          "[::1]/128"
          "${cfg.mailserverIP}/32"
        ];
        transport_maps = [ "hash:/etc/postfix/transport" ];
        smtpd_tls_chain_files = with config.security.acme.certs."${fqdn}"; [
          "${directory}/key.pem"
          "${directory}/fullchain.pem"
        ];
        smtpd_tls_security_level = "may";
        smtpd_recipient_restrictions = [
          "permit_mynetworks"
          "reject_unauth_destination"
          "reject_unverified_recipient"
        ];
        unverified_recipient_reject_code = 550;
      };
    };
  };
}
