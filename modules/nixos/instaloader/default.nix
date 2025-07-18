{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.instaloader;

  instaloaderScript = pkgs.writeShellScriptBin "instaloader-run" ''
    declare -a args

    args+=(--fast-update)
    args+=(--quiet)
    args+=(--no-compress-json)
    args+=(--login "${cfg.login}")
    args+=(--password "$(cat ${cfg.passwordFile})")

    ${optionalString cfg.stories "args+=(--stories)"}
    ${optionalString cfg.reels "args+=(--reels)"}
    ${optionalString (!cfg.posts) "args+=(--no-posts)"}

    args+=(${concatMapStringsSep " " escapeShellArg cfg.profiles})

    ${getExe cfg.package} ''${args[@]}
  '';

  inherit (lib)
    baseNameOf
    concatMapStringsSep
    escapeShellArg
    getExe
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    optionalString
    types
    ;
in
{
  options.services.instaloader = {
    enable = mkEnableOption "The instaloader periodic download service.";

    package = mkPackageOption pkgs "instaloader";

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
      description = "The home directory for the instaloader user. All downloads and session files will be stored here.";
    };

    login = mkOption {
      type = types.str;
      default = "";
      description = "The Instagram username to use for logging in. Required.";
    };

    passwordFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Path to a file containing the password for the Instagram login. Required.";
    };

    profiles = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "A list of Instagram profile names to download.";
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

    posts = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to download posts from the specified profiles.";
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
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.login != "";
        message = "Instaloader: `login` is required.";
      }
      {
        assertion = cfg.passwordFile != null;
        message = "Instaloader: `passwordFile` is required.";
      }
    ];

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
        serviceConfig = {
          Type = "oneshot";
          User = cfg.user;
          Group = cfg.group;
          ExecStart = getExe instaloaderScript;
          StateDirectory = baseNameOf cfg.home;
          PrivateNetwork = false;
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
