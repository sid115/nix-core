{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.matrix-synapse;
  bridge = cfg.bridges.signal;
  matrixPort = 8008;
  fqdn = config.networking.domain;
  olmVersion = "3.2.16";

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
      signal = {
        enable = mkEnableOption "Mautrix-Signal for your Matrix-Synapse instance.";
        admin = mkOption {
          type = types.str;
          description = "The user to give admin permissions to.";
          example = "@admin:example.com";
        };
      };
    };
  };

  config = mkIf (cfg.enable && bridge.enable) {
    nixpkgs = {
      config.permittedInsecurePackages = [ "olm-${olmVersion}" ];
    };

    environment.systemPackages = [ pkgs.mautrix-signal ];

    services.mautrix-signal = {
      enable = true;
      environmentFile = config.sops.templates."mautrix-signal/env-file".path;
      settings = {
        network = {
          displayname_template = mkDefault "{{or .ContactName .ProfileName .PhoneNumber \"Unknown user\" }} (S)";
        };
        bridge = {
          permissions = {
            "*" = mkDefault "relay";
            "${fqdn}" = mkDefault "user";
            "${bridge.admin}" = mkDefault "admin";
          };
        };
        homeserver = {
          address = mkDefault "http://localhost:${toString matrixPort}";
          domain = mkDefault fqdn;
        };
        appservice = {
          address = mkDefault "http://localhost:29328";
          public_address = mkDefault "https://${fqdn}";
          hostname = mkDefault "localhost";
          port = mkDefault 29328;
        };
        provisioning.shared_secret = "$MAUTRIX_SIGNAL_PROVISIONING_SHARED_SECRET";
        public_media = {
          enabled = mkDefault false;
          signing_key = "$MAUTRIX_SIGNAL_PUBLIC_MEDIA_SIGNING_KEY";
        };
        direct_media = {
          enabled = mkDefault false;
          server_key = "$MAUTRIX_SIGNAL_DIRECT_MEDIA_SERVER_KEY";
        };
        backfill = {
          enabled = mkDefault true;
        };
        encryption = {
          allow = mkDefault true;
          default = mkDefault true;
          require = mkDefault false;
          pickle_key = "$MAUTRIX_SIGNAL_ENCRYPTION_PICKLE_KEY";
        };
      };
    };

    sops =
      let
        owner = "mautrix-signal";
        group = "mautrix-signal";
        mode = "0440";
      in
      {
        secrets."mautrix-signal/encryption-pickle-key" = {
          inherit owner group mode;
        };
        secrets."mautrix-signal/provisioning-shared-secret" = {
          inherit owner group mode;
        };
        secrets."mautrix-signal/public-media-signing-key" = {
          inherit owner group mode;
        };
        secrets."mautrix-signal/direct-media-server-key" = {
          inherit owner group mode;
        };
        templates."mautrix-signal/env-file" = {
          inherit owner group mode;
          content = ''
            MAUTRIX_SIGNAL_ENCRYPTION_PICKLE_KEY=${
              config.sops.placeholder."mautrix-signal/encryption-pickle-key"
            }
            MAUTRIX_SIGNAL_PROVISIONING_SHARED_SECRET=${
              config.sops.placeholder."mautrix-signal/provisioning-shared-secret"
            }
            MAUTRIX_SIGNAL_PUBLIC_MEDIA_SIGNING_KEY=${
              config.sops.placeholder."mautrix-signal/public-media-signing-key"
            }
            MAUTRIX_SIGNAL_DIRECT_MEDIA_SERVER_KEY=${
              config.sops.placeholder."mautrix-signal/direct-media-server-key"
            }
          '';
        };
      };
  };
}
