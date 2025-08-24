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

  signal = cfg.bridges.signal;

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
      signal = {
        enable = mkEnableOption "Enable mautrix-signal for your matrix-synapse instance.";
        admin = mkOption {
          type = types.str;
          default = "";
          description = "The user to give admin permissions to.";
          example = "@admin:example.com";
        };
      };
    };
  };

  config = mkIf (cfg.enable && signal.enable) {
    nixpkgs = {
      config.permittedInsecurePackages = [ "olm-${olmVersion}" ];
    };

    environment.systemPackages = [ pkgs.mautrix-signal ];

    services.mautrix-signal = {
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
          network = {
            displayname_template = "{{or .ContactName .ProfileName .PhoneNumber}} (S)";
          };
          permissions = {
            "*" = "relay";
            "${fqdn}" = "user";
            "${signal.admin}" = mkIf (signal.admin != "") "admin";
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
