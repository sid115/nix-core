{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

let
  isNotEmpty = str: builtins.isString str && str != ""; # TODO: put in lib overlay

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
        assertion = isNotEmpty config.networking.domain;
        message = "mailserver: config.networking.domain must be set.";
      }
      {
        assertion = isNotEmpty cfg.subdomain;
        message = "mailserver: config.mailserver.subdomain must be set.";
      }
    ];

    mailserver = {
      fqdn = fqdn;
      domains = mkDefault [ config.networking.domain ];

      certificateScheme = mkDefault "acme-nginx";
    };

    environment.systemPackages = [ pkgs.mailutils ];
  };
}
