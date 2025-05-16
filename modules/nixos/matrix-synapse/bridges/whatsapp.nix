{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.matrix-synapse;
  port = 8008;
  fqdn = "${config.networking.domain}";
  olmVersion = "3.2.16";

  whatsapp = cfg.bridges.whatsapp;

  inherit (lib)
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
          default = "";
          description = "The user to give admin permissions to.";
          example = "@admin:example.com";
        };
      };
    };
  };

  config = mkIf (cfg.enable && whatsapp.enable) {
    nixpkgs = {
      config.permittedInsecurePackages = [ "olm-${olmVersion}" ];
    };

    environment.systemPackages = [ pkgs.mautrix-whatsapp ];

    services.mautrix-whatsapp = {
      enable = true;
      settings = {
        homeserver = {
          address = "http://localhost:${toString port}";
        };
        bridge = {
          encryption = {
            allow = true;
            default = true;
            require = true;
          };
          double_puppet_server_map = {
            "${cfg.settings.server_name}" = "https://${cfg.settings.server_name}";
          };
          history_sync = {
            request_full_sync = true;
          };
          mute_bridging = true;
          displayname_template = "{{or .FullName .BusinessName .PushName .Phone}} (WA)";
          user_avatar_sync = true;
          url_previews = false;
          permissions = {
            "*" = "relay";
            "${fqdn}" = "user";
            "${whatsapp.admin}" = mkIf (whatsapp.admin != "") "admin";
          };
          private_chat_portal_meta = true;
          provisioning = {
            shared_secret = "disable";
          };
        };
      };
    };
  };
}
