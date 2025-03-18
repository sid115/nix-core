{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.nextcloud-sync;
  syncScript = pkgs.writeShellScript "_nextcloud-sync" ''
    LOCAL=$1
    REMOTE=$2
    PASSWORD=$(${pkgs.coreutils}/bin/cat ${cfg.passwordFile})
    if [ -z $PASSWORD ]; then
      ${pkgs.libnotify}/bin/notify-send "Nextcloud Sync Error" "No password found in ${cfg.passwordFile}"
      exit 1
    fi          
    ${pkgs.nextcloud-client}/bin/nextcloudcmd -h -n --path $REMOTE $LOCAL https://${cfg.username}:$PASSWORD@${cfg.remote}
    ${pkgs.libnotify}/bin/notify-send "Nextcloud Sync" "Synced $LOCAL with $REMOTE"
  '';
  manualSyncScript = pkgs.writeShellScriptBin "nextcloud-sync-all" ''
    ${pkgs.libnotify}/bin/notify-send "Nextcloud Manual Sync" "Starting manual sync of all configured directories."

    ${concatMapStrings (dir: ''
      echo "Starting sync service: nextcloud-sync-${baseNameOf dir.local}"
      systemctl --user start nextcloud-sync-${baseNameOf dir.local}
    '') cfg.connections}
  '';

  inherit (lib)
    concatMapStrings
    foldl'
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in
{
  options.services.nextcloud-sync = {
    enable = mkEnableOption "Enable Nextcloud sync systemd services via nextcloudcmd.";
    username = mkOption {
      type = types.str;
      default = config.home.username;
      description = "Username for Nextcloud authentication.";
    };
    passwordFile = mkOption {
      type = types.path;
      description = "File containing only Nextcloud password for your user.";
    };
    remote = mkOption {
      type = types.str;
      example = "nextcloud.example.com";
      description = "The remote Nextcloud server domain name.";
    };
    initTimer = mkOption {
      type = types.str;
      default = "1min";
      description = "The time to wait after booting up before starting the sync services.";
    };
    rerunTimer = mkOption {
      type = types.str;
      default = "20min";
      description = "The time to wait before rerunning the sync services.";
    };
    connections = mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            local = mkOption {
              type = types.str;
              description = "The local directory path to sync.";
            };
            remote = mkOption {
              type = types.str;
              description = "The remote directory path in Nextcloud.";
            };
          };
        }
      );
      default = [ ];
      description = ''
        A list of sync connections. Each entry represents a directory sync configuration.
        Each element requires:
          - `local`: the local directory path.
          - `remote`: the remote folder path.
      '';
      example = [
        {
          local = "/home/you/Documents";
          remote = "/documents";
        }
      ];
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.libnotify
      manualSyncScript
    ];

    # Systemd user services for Nextcloud sync.
    systemd.user.services = foldl' (
      acc: dir:
      acc
      // {
        "nextcloud-sync-${baseNameOf dir.local}" = {
          Unit = {
            Description = "Auto sync Nextcloud: ${dir.local} <-> ${dir.remote}";
            After = "network-online.target";
            ConditionPathExists = cfg.passwordFile;
          };
          Service = {
            Type = "simple";
            ExecStart = "${syncScript} ${dir.local} ${dir.remote}";
            TimeoutStopSec = "180";
            KillMode = "process";
            KillSignal = "SIGINT";
          };
          Install.WantedBy = [ "default.target" ];
        };
      }
    ) { } cfg.connections;

    # Systemd timers corresponding to nextcloud sync services.
    systemd.user.timers = foldl' (
      acc: dir:
      acc
      // {
        "nextcloud-sync-${baseNameOf dir.local}" = {
          Unit.Description = "Nextcloud sync timer.";
          Timer = {
            OnBootSec = cfg.initTimer;
            OnUnitActiveSec = cfg.rerunTimer;
          };
          Install.WantedBy = [
            "multi-user.target"
            "timers.target"
          ];
        };
      }
    ) { } cfg.connections;
  };
}
