{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.mailserver;
  fqdn = "${cfg.subdomain}.${config.networking.domain}";

  inherit (lib)
    mkDefault
    mkIf
    mkOption
    types
    ;
in
{
  imports = [ inputs.nixos-mailserver.nixosModules.mailserver ];

  options.mailserver = {
    subdomain = mkOption {
      type = types.str;
      default = "mail";
      description = "Subdomain for rDNS";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.subdomain != "";
        message = "nix-core/nixos/mailserver: config.mailserver.subdomain cannot be empty.";
      }
    ];

    mailserver = {
      inherit fqdn;

      domains = mkDefault [ config.networking.domain ];
      x509.useACMEHost = config.mailserver.fqdn;
      stateVersion = mkDefault 1;
    };

    security.acme = {
      acceptTerms = true;
      defaults.email = "postmaster@${config.networking.domain}";
      defaults.webroot = "/var/lib/acme/acme-challenge";
    };

    environment.systemPackages = [ pkgs.mailutils ];
  };
}
