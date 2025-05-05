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
        assertion = isNotEmpty cfg.subdomain;
        message = "nix-core/nixos/mailserver: config.mailserver.subdomain cannot be empty.";
      }
      {
        assertion = config.services.nginx.enable;
        message = "nix-core/nixos/mailserver: config.services.nginx.enable has to be true.";
      }
    ];

    mailserver = {
      inherit fqdn;

      enable = mkDefault true;
      domains = mkDefault [ config.networking.domain ];
      certificateScheme = mkDefault "acme-nginx";
    };

    environment.systemPackages = [ pkgs.mailutils ];
  };
}
