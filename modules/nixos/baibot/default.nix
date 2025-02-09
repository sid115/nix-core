{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.baibot;
  homeDir = "/var/lib/baibot";

  defaultConfig = {
    homeserver = {
      server_name = config.networking.domain;
      url = "http://127.0.0.1:8008";
    };
    user = {
      mxid_localpart = "baibot";
      password = "baibot";
      name = "baibot";
      encryption = {
        recovery_passphrase = "long-and-secure-passphrase-here";
        recovery_reset_allowed = false;
      };
    };
    command_prefix = "!bai";
    access.admin_patterns = [
      "@admin:${config.networking.domain}"
    ];
    persistence = {
      data_dir_path = "${homeDir}/data";
      session_encryption_key = "9701cd109ed56770687dd8410f7d7371a4390dd3feb8ed721f189a0756c40098";
      config_encryption_key = "a9f1df98d288802ead20a8be2c701a627eabd31cf3d9e2aea28867ccd7a4ded7";
    };
    agents.static_definitions = [ ];
    initial_global_config = {
      handler = {
        catch_all = null;
        text_generation = null;
        text_to_speech = null;
        speech_to_text = null;
        image_generation = null;
      };
      user_patterns = [
        "@*:${config.networking.domain}"
      ];
    };
    logging = "warn,mxlink=debug,baibot=debug";
  };

  configFile = (pkgs.formats.yaml { }).generate "baibot-config" {
    inherit (cfg) config;
  };

  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in
{
  options = {
    services.baibot = {
      enable = mkEnableOption "Enable the baibot service, a Matrix AI bot.";

      config = mkOption {
        type = types.attrs;
        default = defaultConfig;
        description = "TODO";
      };

      package = mkOption {
        type = types.nullOr types.package;
        default = null;
        description = ''
          The baibot package to use for the service. This must be set by the user,
          as there is no default baibot package available in Nixpkgs.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.package != null;
        message = "The baibot package is not specified. Please set the services.baibot.package option to a valid baibot package.";
      }
    ];

    users = {
      users.baibot = {
        isSystemUser = true;
        description = "Baibot system user";
        home = homeDir;
        createHome = true;
        group = "baibot";
      };
      groups.baibot = { };
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.config.persistence.data_dir_path} 0755 baibot baibot -"
    ];

    systemd.services.baibot = {
      description = "Baibot Service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      environment = {
        BAIBOT_CONFIG_FILE_PATH = "${configFile}";
        BAIBOT_PERSISTENCE_DATA_DIR_PATH = "${cfg.config.persistence.data_dir_path}";
      };
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/baibot";
        Restart = "always";
        User = "baibot";
        Group = "baibot";
      };
    };
  };
}
