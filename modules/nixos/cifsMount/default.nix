{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.cifsMount;
in
{

  options.services.cifsMount = {
    enable = mkEnableOption "CIFS mounting of predefined remote directories.";

    # List of predefined remote CIFS shares to mount
    remotes = mkOption {
      type = with types; listOf (attrsOf str);
      default = [ ];
      description = "List of predefined remote CIFS shares to mount.";
      example = [
        {
          # Example entry for a CIFS mount.
          host = "remotehost";
          shareName = "share";
          mountPoint = "/local/mountpoint";
          credentialsFile = "/path/to/credentials";
          user = "yourusername";
        }
      ];
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ cifs-utils ];

    # Define /etc/fstab entries for each remote CIFS share
    fileSystems = fold (
      remote: fs:
      let
        mountOption = "credentials=${remote.credentialsFile},uid=${remote.user},gid=${remote.user},user,noauto";
      in
      fs
      // {
        "${toString remote.mountPoint}" = {
          device = "//${remote.host}/${remote.shareName}";
          fsType = "cifs";
          options = [
            (optionalString (remote.credentialsFile != null) "credentials=${remote.credentialsFile}")
            "uid=${remote.user}"
            "gid=${remote.user}"
            "user"
            "noauto"
          ];
        };
      }
    ) { } cfg.remotes;

    # Create systemd user services for each remote CIFS share
    systemd.user.services = fold (
      remote: services:
      let
        serviceName = "cifs-mount-${remote.shareName}";
      in
      {
        ${serviceName} = {
          description = "Mount remote share: //${remote.host}/${remote.shareName} to ${remote.mountPoint}";
          wantedBy = [ "graphical-session.target" ];
          after = [ "graphical-session.target" ];

          # Service configuration to mount and unmount CIFS share
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart = "mount //${remote.host}/${remote.shareName}";
            ExecStop = "umount //${remote.host}/${remote.shareName}";
            Restart = "on-failure";
          };
        };
      }
      // services
    ) { } cfg.remotes;

    # Ensure that all cifs-mount services are started with the graphical session
    systemd.user.targets.graphical-session.wants = map (
      remote: "cifs-mount-${remote.shareName}.service"
    ) cfg.remotes;
  };
}
