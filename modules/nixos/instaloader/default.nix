{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.instaloader;
  sessionFile = "${cfg.home}/.config/instaloader/session-${cfg.login}";
  passwordFile = if (cfg.passwordFile != null) then "${cfg.passwordFile}" else "";

  instaloaderScript = pkgs.writeShellScriptBin "instaloader-run" ''
    declare -a args

    args+=(--fast-update)
    args+=(--quiet)
    args+=(--no-compress-json)
    args+=(--login "${cfg.login}")

    # Skip password authentication if session file exists
    if [[ ! -r "${sessionFile}" ]]; then
      if [[ ! -r "${passwordFile}" ]]; then
        echo "Error: Instaloader password file '${passwordFile}' not found or not readable." >&2
        exit 1
      fi
      args+=(--password "$(cat "${passwordFile}")")
    fi

    ${optionalString cfg.stories "args+=(--stories)"}
    ${optionalString cfg.reels "args+=(--reels)"}
    ${optionalString cfg.highlights "args+=(--highlights)"}
    ${optionalString (!cfg.posts) "args+=(--no-posts)"}

    args+=(${concatMapStringsSep " " escapeShellArg cfg.extraArgs})

    args+=(${concatMapStringsSep " " escapeShellArg cfg.profiles})

    ${getExe cfg.package} ''${args[@]}
  '';

  inherit (lib)
    concatMapStringsSep
    escapeShellArg
    getExe
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    optionalAttrs
    optionalString
    types
    ;
in
{
  options.services.instaloader = {
    enable = mkEnableOption "The instaloader periodic download service.";

    package = mkPackageOption pkgs "instaloader" { };

    user = mkOption {
      type = types.str;
      default = "instaloader";
      description = "The user to run the instaloader service as.";
    };

    group = mkOption {
      type = types.str;
      default = "instaloader";
      description = "The group to run the instaloader service as.";
    };

    home = mkOption {
      type = types.path;
      default = "/var/lib/instaloader";
      description = "The home directory for the instaloader user. All downloads will be stored here.";
    };

    login = mkOption {
      type = types.str;
      default = "";
      description = "The Instagram username to use for logging in. Required.";
    };

    passwordFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Path to a file containing the password for the Instagram login. Required if no session file exists.";
    };

    profiles = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "A list of Instagram profile names to download. Must have at least one entry.";
    };

    stories = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to download stories from the specified profiles (requires login).";
    };

    reels = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to download Reels from the specified profiles.";
    };

    highlights = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to download Highlights from the specified profiles.";
    };

    posts = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to download posts from the specified profiles.";
    };

    extraArgs = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "--post-filter='date_utc >= datetime(2025, 1, 1)'" ];
      description = "Additional command line arguments to pass to instaloader.";
    };

    timer = {
      onCalendar = mkOption {
        type = types.str;
        default = "daily";
        example = "hourly";
        description = ''
          The `OnCalendar` expression for the systemd timer.
          See `man systemd.time` for syntax.
        '';
      };

      persistent = mkOption {
        type = types.bool;
        default = true;
        description = "If true, the service will run immediately after a boot if it missed its last scheduled time.";
      };
    };

    retry = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to automatically restart the service if it fails (e.g. due to rate limiting).";
      };

      delay = mkOption {
        type = types.str;
        default = "20min";
        description = ''
          How long to wait before retrying after a failure.
          Use systemd time format (e.g., "10s", "5min", "1h").
        '';
      };

      attempts = mkOption {
        type = types.int;
        default = 3;
        description = "How many times to retry within a single activation before giving up.";
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.login != "";
        message = "Instaloader: `login` is required.";
      }
      {
        assertion = cfg.profiles != [ ];
        message = "Instaloader: `profiles` must have at least one entry.";
      }
    ];
    warnings =
      if (cfg.passwordFile == null) then
        [ "Instaloader: `passwordFile` is null. Relying on session file ${sessionFile}" ]
      else
        [ ];

    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
      home = cfg.home;
      description = "Instaloader service user";
    };
    users.groups.${cfg.group} = { };

    systemd = {
      services.instaloader = {
        description = "Download media from Instagram profiles";
        serviceConfig =
          {
            Type = "oneshot";
            User = cfg.user;
            Group = cfg.group;
            ExecStart = getExe instaloaderScript;
            WorkingDirectory = cfg.home;
            PrivateNetwork = false;
          }
          // optionalAttrs cfg.retry.enable {
            Restart = "on-failure";
            RestartSec = cfg.retry.delay;
            StartLimitBurst = cfg.retry.attempts;
          };
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
      };

      timers.instaloader = {
        description = "Periodically run instaloader";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = cfg.timer.onCalendar;
          Persistent = cfg.timer.persistent;
          Unit = "instaloader.service";
        };
      };
    };
  };
}
