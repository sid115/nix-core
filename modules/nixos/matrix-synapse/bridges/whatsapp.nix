{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.matrix-synapse;
  matrixPort = 8008;
  fqdn = config.networking.domain;
  olmVersion = "3.2.16";

  bridge = config.services.mautrix-whatsapp;

  inherit (lib)
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in
{
  options.services.matrix-synapse = {
    bridges = {
      whatsapp = {
        enable = mkEnableOption "Enable mautrix-whatsapp for your matrix-synapse instance.";
        admin = mkOption {
          type = types.str;
          description = "The user to give admin permissions to.";
          example = "@admin:example.com";
        };
      };
    };
  };

  config = mkIf (cfg.enable && cfg.bridges.whatsapp.enable) {
    nixpkgs = {
      config.permittedInsecurePackages = [ "olm-${olmVersion}" ];
    };

    environment.systemPackages = [ pkgs.mautrix-whatsapp ];

    services.mautrix-whatsapp = {
      enable = true;
      settings = {
        network = {
          displayname_template = mkDefault "{{or .FullName .BusinessName .PushName .Phone}} (WA)";
          history_sync = {
            request_full_sync = mkDefault true;
          };
        };
        bridge = {
          permissions = {
            "*" = mkDefault "relay";
            "${fqdn}" = mkDefault "user";
            "${cfg.bridges.whatsapp.admin}" = mkDefault "admin";
          };
        };
        homeserver = {
          address = mkDefault "http://localhost:${toString matrixPort}";
          domain = mkDefault fqdn;
        };
        appservice = {
          address = mkDefault "http://localhost:${toString bridge.settings.appservice.port}";
          public_address = mkDefault "https://${fqdn}";
          hostname = mkDefault "localhost";
          port = mkDefault 29318;
        };
        public_media = {
          enabled = mkDefault false;
        };
        direct_media = {
          enabled = mkDefault false;
        };
        backfill = {
          enabled = mkDefault true;
        };
        encryption = {
          allow = mkDefault true;
          default = mkDefault true;
          require = mkDefault true;
        };
      };
    };
  };
}
