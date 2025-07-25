{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.gemini-cli;

  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in
{
  options.programs.gemini-cli = {
    enable = mkEnableOption "Enable gemini-cli.";

    package = mkOption {
      type = types.package;
      description = "The package to use for gemini-cli.";
      default = pkgs.gemini-cli;
    };

    settings = mkOption {
      type = types.attrs;
      description = ''
        A set of attributes that will be translated into the JSON configuration file for gemini-cli.
        Available settings:
        https://github.com/google-gemini/gemini-cli/blob/main/docs/cli/configuration.md
      '';
      default = {
        preferredEditor = "nvim";
        usageStatisticsEnabled = false;
        theme = "Default";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    home.file = {
      ".gemini/settings.json".source = pkgs.writeText "gemini-cli-settings.json" (
        builtins.toJSON cfg.settings
      );
    };
  };
}
