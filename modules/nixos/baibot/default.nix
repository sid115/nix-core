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
      name = "baibot";
      password = "baibot";
      encryption = {
        recovery_passphrase = "super-secret-key";
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
    agents = {
      static_definitions = [
        {
          id = "openai";
          provider = "openai";
          config = {
            base_url = "https://api.openai.com/v1";
            api_key = ""; # placeholder
            text_generation = {
              model_id = "gpt-4o";
              prompt = ''
                You are a brief, but helpful bot called {{ baibot_name }} powered by the {{ baibot_model_id }} model.
                The date/time of this conversation's start is: {{ baibot_conversation_start_time_utc }}.
              '';
              temperature = 1.0;
              max_response_tokens = 16384;
              max_context_tokens = 128000;
            };
            speech_to_text = {
              model_id = "whisper-1";
            };
            text_to_speech = {
              model_id = "tts-1-hd";
              voice = "onyx";
              speed = 1.0;
              response_format = "opus";
            };
            image_generation = {
              model_id = "dall-e-3";
              style = "vivid";
              size = "1024x1024";
              quality = "standard";
            };
          };
        }
      ];
    };
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

  finalConfig = mergeAttrs defaultConfig cfg.config;

  configFile = (pkgs.formats.yaml { }).generate "baibot-config.yml" finalConfig;

  inherit (lib)
    mergeAttrs
    mkEnableOption
    mkIf
    mkOption
    optional
    types
    ;
in
{
  options = {
    services.baibot = {
      enable = mkEnableOption "Enable the baibot service, a Matrix AI bot.";

      config = mkOption {
        type = types.attrs;
        default = { };
        description = ''
          Configuration for the baibot service. This will be merged with the default configuration.
          For static configuration options, see:
          https://github.com/etkecc/baibot/blob/main/etc/app/config.yml.dist
        '';
        example = {
          access.admin_patterns = [ "@you:example.com" ];
          initial_global_config = {
            handler = {
              text_generation = "static/openai";
              text_to_speed = "static/openai";
              speech_to_text = "static/openai";
              image_generation = "static/openai";
            };
            user_patterns = [
              "@you:example.com"
            ];
          };
        };
      };

      environmentFile = lib.mkOption {
        description = ''
          Path to an environment file that is passed to the systemd service for securely handling secrets.
          This file should contain key-value pairs in the format `KEY="value"` and must include the following required secrets:
            - BAIBOT_USER_PASSWORD: The password for the Matrix user "baibot". This is required to authenticate the bot with the homeserver.
            - BAIBOT_ENCRYPTION_RECOVERY_PASSPHRASE: A secure passphrase used for encryption key recovery. Required for secure message storage.
            - BAIBOT_PERSISTENCE_SESSION_ENCRYPTION_KEY: A 64-character hex key (generated using `openssl rand -hex 32`) for encrypting session data.
            - BAIBOT_PERSISTENCE_CONFIG_ENCRYPTION_KEY: Another 64-character hex key for encrypting configuration data.

          Optional secrets include:
            - BAIBOT_AGENTS_OPENAI_API_KEY: API key for OpenAI services if you intend to use text generation, speech-to-text, or other integrations.
        '';
        type = lib.types.nullOr lib.types.path;
        default = null;
        example = "/var/lib/secrets/baibot.env";
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
      "d ${finalConfig.persistence.data_dir_path} 0755 baibot baibot -"
    ];

    systemd.services.baibot = {
      description = "Baibot Service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      environment = {
        BAIBOT_CONFIG_FILE_PATH = configFile;
        BAIBOT_PERSISTENCE_DATA_DIR_PATH = "${finalConfig.persistence.data_dir_path}";
      };
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/baibot";
        EnvironmentFile = optional (cfg.environmentFile != null) cfg.environmentFile;
        Restart = "always";
        User = "baibot";
        Group = "baibot";
      };
    };
  };
}
