{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.uptime-kuma-agent;

  monitorSubmodule =
    { name, config, ... }:
    {
      options = {
        enable = mkEnableOption "this specific monitor" // {
          default = true;
        };

        serviceName = mkOption {
          type = types.str;
          default = name;
          description = "The exact name of the systemd service to check";
        };

        secretFile = mkOption {
          type = types.path;
          description = "Path to the file containing the Uptime Kuma Push URL.";
        };

        cronSchedule = mkOption {
          type = types.str;
          default = "* * * * *"; # every minute
          description = "Cron expression for how often to check the status.";
        };
      };
    };

  mkCheckScript =
    name: monitorCfg:
    pkgs.writeShellScript "check-kuma-${name}" ''

      if [ ! -f "${monitorCfg.secretFile}" ]; then
        echo "Secret file ${monitorCfg.secretFile} not found. Skipping."
        exit 1
      fi

      PUSH_URL=$(cat "${monitorCfg.secretFile}" | tr -d '\n')

      if systemctl -q is-active "${monitorCfg.serviceName}"; then
        STATUS_PARAMS="status=up&msg=OK"
      else
        STATUS_PARAMS="status=down&msg=Service+inactive"
      fi

      if [[ "$PUSH_URL" == *"?"* ]]; then
        GLUE="&"
      else
        GLUE="?"
      fi

      ${pkgs.curl}/bin/curl -fsS "$PUSH_URL$GLUE$STATUS_PARAMS&ping="
    '';

  inherit (lib)
    mapAttrsToList
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in
{
  options.services.uptime-kuma-agent = {
    enable = mkEnableOption "Uptime Kuma systemd push agent";

    monitors = mkOption {
      type = types.attrsOf (types.submodule monitorSubmodule);
      default = { };
      description = "Attribute set of services to monitor.";
      example = {
        nginx = {
          serviceName = "nginx";
          secretFile = "config.sops.secrets.kuma_nginx_url.path";
          cronSchedule = "*/5 * * * *";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    services.cron.enable = true;

    services.cron.systemCronJobs = mapAttrsToList (
      name: monitorCfg:
      if monitorCfg.enable then "${monitorCfg.cronSchedule} root ${mkCheckScript name monitorCfg}" else ""
    ) cfg.monitors;
  };
}
