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
    mailserver = {
      fqdn = fqdn;
      domains = mkDefault [ config.networking.domain ];

      certificateScheme = mkDefault "acme-nginx";
    };

    environment.systemPackages = [ pkgs.mailutils ];
  };
}
