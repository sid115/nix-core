{ config, lib, ... }:

# Set in your SNM config:
# relayHost = "[SMTP_RELAY_SERVER_IP]"; # `[]` tell Postfix to use IP address (no MX lookup)
# relayPort = 25;
# relaySsl = null; # let Tailscale handle encryption

let
  cfg = config.services.smtp-relay;

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
    interface = mkOption {
      type = types.str;
      description = "Network interface to bind the SMTP relay server";
      example = "tailscale0";
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.interfaces."${cfg.interface}".allowedTCPPorts = [ 25 ];

    services.postfix = {
      enable = true;
      hostname = "${cfg.subdomain}.${config.networking.domain}";
      config = {
        inet_interfaces = "all";
        inet_protocols = "ipv4";
        mynetworks = "127.0.0.0/8 [::1]/128 ${cfg.mailserverIP}/32";
        smtp_tls_security_level = "may";
        smtpd_recipient_restrictions = "permit_mynetworks, reject_unauth_destination";
      };
    };
  };
}
