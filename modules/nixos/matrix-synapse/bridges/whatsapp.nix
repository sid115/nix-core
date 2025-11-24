{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.matrix-synapse;
  bridge = cfg.bridges.whatsapp;
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
      whatsapp = {
        enable = mkEnableOption "Mautrix-Whatsapp for your Matrix-Synapse instance.";
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

    environment.systemPackages = [ pkgs.mautrix-whatsapp ];

    services.mautrix-whatsapp = {
      enable = true;
      environmentFile = config.sops.templates."mautrix-whatsapp/env-file".path;
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
            "${bridge.admin}" = mkDefault "admin";
          };
        };
        homeserver = {
          address = mkDefault "http://localhost:${toString matrixPort}";
          domain = mkDefault fqdn;
        };
        appservice = {
          address = mkDefault "http://localhost:29318";
          public_address = mkDefault "https://${fqdn}";
          hostname = mkDefault "localhost";
          port = mkDefault 29318;
        };
        provisioning.shared_secret = "$MAUTRIX_WHATSAPP_PROVISIONING_SHARED_SECRET";
        public_media = {
          enabled = mkDefault false;
          signing_key = "$MAUTRIX_WHATSAPP_PUBLIC_MEDIA_SIGNING_KEY";
        };
        direct_media = {
          enabled = mkDefault false;
          server_key = "$MAUTRIX_WHATSAPP_DIRECT_MEDIA_SERVER_KEY";
        };
        backfill = {
          enabled = mkDefault true;
        };
        encryption = {
          allow = mkDefault true;
          default = mkDefault true;
          require = mkDefault false;
          pickle_key = "$MAUTRIX_WHATSAPP_ENCRYPTION_PICKLE_KEY";
        };
      };
    };

    sops =
      let
        owner = "mautrix-whatsapp";
        group = "mautrix-whatsapp";
        mode = "0440";
      in
      {
        secrets."mautrix-whatsapp/encryption-pickle-key" = {
          inherit owner group mode;
        };
        secrets."mautrix-whatsapp/provisioning-shared-secret" = {
          inherit owner group mode;
        };
        secrets."mautrix-whatsapp/public-media-signing-key" = {
          inherit owner group mode;
        };
        secrets."mautrix-whatsapp/direct-media-server-key" = {
          inherit owner group mode;
        };
        templates."mautrix-whatsapp/env-file" = {
          inherit owner group mode;
          content = ''
            MAUTRIX_WHATSAPP_ENCRYPTION_PICKLE_KEY=${
              config.sops.placeholder."mautrix-whatsapp/encryption-pickle-key"
            }
            MAUTRIX_WHATSAPP_PROVISIONING_SHARED_SECRET=${
              config.sops.placeholder."mautrix-whatsapp/provisioning-shared-secret"
            }
            MAUTRIX_WHATSAPP_PUBLIC_MEDIA_SIGNING_KEY=${
              config.sops.placeholder."mautrix-whatsapp/public-media-signing-key"
            }
            MAUTRIX_WHATSAPP_DIRECT_MEDIA_SERVER_KEY=${
              config.sops.placeholder."mautrix-whatsapp/direct-media-server-key"
            }
          '';
        };
      };
  };
}
