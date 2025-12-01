{
  config,
  pkgs,
  lib,
  ...
}:

# Set `networking.hostId` to:
# $ head -c 8 /etc/machine-id

# Mark datasets to snapshot:
# $ sudo zfs set com.sun:auto-snapshot:daily=true dpool/data/backup

# Generate SSH key for replication (empty passphrase):
# $ sudo -i ssh-keygen -t rsa -b 4096 -f /root/.ssh/zfs-replication

let
  cfg = config.services.zfs;

  pushURLFile = config.sops.secrets."zfs/kuma-push-url".path;
  notifyScript =
    name:
    pkgs.writeShellScript "zfs-kuma-${name}" ''
      if [ ! -f "${pushURLFile}" ]; then
        echo "File ${pushURLFile} not found. Skipping."
        exit 1
      fi

      PUSH_URL=$(cat "${pushURLFile}" | tr -d '\n')

      if [ "$EXIT_STATUS" == "0" ]; then
        STATUS_PARAMS="status=up&msg=OK"
      else
        STATUS_PARAMS="status=down&msg=${name}+failed"
      fi

      if [[ "$PUSH_URL" == *"?"* ]]; then
        GLUE="&"
      else
        GLUE="?"
      fi

      ${pkgs.curl}/bin/curl -fsS "$PUSH_URL$GLUE$STATUS_PARAMS&ping="
    '';

  inherit (lib) mkDefault mkForce optionalAttrs;
in
{
  boot.supportedFilesystems = [ "zfs" ];
  boot.loader.systemd-boot.enable = mkForce false;
  boot.loader.grub.enable = mkForce true;
  boot.loader.grub.zfsSupport = mkForce true;

  services.zfs.trim = {
    enable = mkDefault true;
    interval = mkDefault "weekly";
  };

  services.zfs.srub = {
    enable = mkDefault true;
    interval = mkDefault "monthly";
  };

  services.zfs.autoSnapshot = {
    enable = mkDefault true;
    flags = mkDefault "-k -p --utc";
    frequent = mkDefault 0;
    hourly = mkDefault 24;
    daily = mkDefault 7;
    weekly = mkDefault 4;
    monthly = mkDefault 0;
  };

  services.zfs.autoReplication = {
    username = mkDefault "root";
    identityFilePath = mkDefault "/root/.ssh/zfs-replication";
    followDelete = mkDefault true;
  };

  systemd.services = {
    zfs-replication.serviceConfig = {
      ExecStopPost = [ "${notifyScript "replication"}" ];
    };
    zfs-snapshot-frequent.serviceConfig =
      optionalAttrs cfg.autoSnapshot.frequent > 0 {
        ExecStopPost = [ "${notifyScript "frequent+snapshot"}" ];
      };
    zfs-snapshot-hourly.serviceConfig =
      optionalAttrs cfg.autoSnapshot.hourly > 0 {
        ExecStopPost = [ "${notifyScript "hourly+snapshot"}" ];
      };
    zfs-snapshot-daily.serviceConfig =
      optionalAttrs cfg.autoSnapshot.daily > 0 {
        ExecStopPost = [ "${notifyScript "daily+snapshot"}" ];
      };
    zfs-snapshot-weekly.serviceConfig =
      optionalAttrs cfg.autoSnapshot.weekly > 0 {
        ExecStopPost = [ "${notifyScript "weekly+snapshot"}" ];
      };
    zfs-snapshot-monthly.serviceConfig =
      optionalAttrs cfg.autoSnapshot.monthly > 0 {
        ExecStopPost = [ "${notifyScript "monthly+snapshot"}" ];
      };
  };

  environment.systemPackages = with pkgs; [ lz4 ];

  sops.secrets."zfs/kuma-push-url" = { };
}
