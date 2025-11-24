{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.baibot;
  homeDir = "/var/lib/baibot";

  inherit (lib)
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
      enable = mkEnableOption "Baibot, a Matrix AI bot.";

      configFile = mkOption {
        type = types.nullOr types.path;
        default = "${homeDir}/config.yml";
        description = ''
          Path to the baibot configuration file. Use the template for reference:
          https://github.com/etkecc/baibot/blob/main/etc/app/config.yml.dist
        '';
      };

      persistenceDataDirPath = mkOption {
        type = types.nullOr types.path;
        default = "${homeDir}/data";
        description = ''
          Path to the directory where baibot will store its persistent data.
        '';
      };

      environmentFile = lib.mkOption {
        description = ''
          Path to an environment file that is passed to the systemd service.
        '';
        type = lib.types.nullOr lib.types.path;
        default = null;
        example = "/run/secrets/baibot";
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

    systemd.services.baibot = {
      description = "Baibot Service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      environment = {
        BAIBOT_CONFIG_FILE_PATH = cfg.configFile;
        BAIBOT_PERSISTENCE_DATA_DIR_PATH = cfg.persistenceDataDirPath;
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
