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
      type = types.nullOr types.package;
      description = "The package to use for gemini-cli. You have to provide it yourself.";
      default = null;
    };

    apiKeyFile = mkOption {
      type = types.nullOr types.path;
      description = ''
        The path to the file containing your Gemini API key.
        If set, this will be used to authenticate with the Gemini API.
      '';
      default = null;
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
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = (cfg.package != null);
        message = "You must provide a package for gemini-cli.";
      }
    ];

    home.packages = [ cfg.package ];

    home.file = {
      ".gemini/settings.json".source = pkgs.writeText "gemini-cli-settings.json" (
        builtins.toJSON cfg.settings
      );
      ".gemeni/.env".source = mkIf (cfg.apiKeyFile != null) ''
        GEMINI_API_KEY=$(cat ${cfg.apiKeyFile})
      '';
    };
  };
}
