{ config, lib, ... }:

let
  cfg = config.services.baibot;
  defaultConfigPath = "/etc/baibot/config.yml";
  defaultDataDir = "/var/lib/baibot/data";

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
      configFile = mkOption {
        type = types.path;
        default = defaultConfigPath;
        description = "Path to the baibot configuration file.";
      };
      dataDir = mkOption {
        type = types.path;
        default = defaultDataDir;
        description = "Path to the baibot data directory.";
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
        home = "/var/lib/baibot";
        createHome = true;
        group = "baibot";
      };
      groups.baibot = { };
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0755 baibot baibot -"
    ];

    systemd.services.baibot = {
      description = "Baibot Service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      environment = {
        BAIBOT_CONFIG_FILE_PATH = "${cfg.configFile}";
        BAIBOT_PERSISTENCE_DATA_DIR_PATH = "${cfg.dataDir}";
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
