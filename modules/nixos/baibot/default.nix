{ config, lib, ... }:

let
  cfg = config.services.baibot;
  defaultConfigPath = "/etc/baibot/config.yml";

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

    systemd.services.baibot = {
      description = "Baibot Service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/baibot";
        Environment = "BAIBOT_CONFIG_FILE_PATH=${cfg.configFile}";
        Restart = "always";
        User = "baibot";
        Group = "baibot";
      };
    };
  };
}
