{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.mailserver;
  domain = config.networking.domain;
  fqdn = "${cfg.subdomain}.${domain}";

  inherit (lib)
    attrNames
    genAttrs
    mapAttrs'
    mkDefault
    mkIf
    mkOption
    nameValuePair
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
    accounts = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            aliases = mkOption {
              type = types.listOf types.str;
              default = [ ];
              description = "A list of aliases of this account. `@domain` will be appended automatically.";
            };
            sendOnly = mkOption {
              type = types.bool;
              default = false;
              description = "Specifies if the account should be a send-only account.";
            };
          };
        }
      );
      default = { };
      description = ''
        This options wraps `loginAccounts`.
        `loginAccounts.<attr-name>.name` will be automatically set to `<attr-name>@<domain>`.
      '';
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

      domains = mkDefault [ domain ];
      x509.useACMEHost = config.mailserver.fqdn;
      stateVersion = mkDefault 1;

      loginAccounts = genAttrs (attrNames cfg.accounts) (user: {
        name = "${user}@${domain}";
        aliases = map (alias: "${alias}@${domain}") (cfg.accounts.${user}.aliases or [ ]);
        sendOnly = cfg.accounts.${user}.sendOnly;
        quota = mkDefault "5G";
        hashedPasswordFile = config.sops.secrets."mailserver/accounts/${user}".path;
      });
    };

    security.acme = {
      acceptTerms = true;
      defaults.email = "postmaster@${domain}";
      defaults.webroot = "/var/lib/acme/acme-challenge";
    };

    environment.systemPackages = [ pkgs.mailutils ];

    sops = {
      secrets = mapAttrs' (user: _config: nameValuePair "mailserver/accounts/${user}" { }) cfg.accounts;
    };
  };
}
