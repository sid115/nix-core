{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.stylix;

  # all valid options for `cfg.scheme`
  validSchemes = [
    "ayu"
    "dracula"
    "gruvbox"
    "moonfly"
    "nord"
    "oxocarbon"
  ];
  # schemes names in `pkgs.base16-schemes` that need a suffix
  needsSuffix = [
    "ayu"
    "gruvbox"
  ];
  # schemes in ./schemes
  customSchemes = [
    "moonfly"
    "oxocarbon"
  ];
  schemeName =
    if builtins.elem cfg.scheme needsSuffix then "${cfg.scheme}-${cfg.polarity}" else cfg.scheme;
  scheme =
    if builtins.elem cfg.scheme customSchemes then
      ./schemes/${schemeName}.yaml
    else
      "${pkgs.base16-schemes}/share/themes/${schemeName}.yaml";

  inherit (lib)
    mkDefault
    mkIf
    types
    ;
in
{
  imports = [
    inputs.stylix.homeModules.stylix

    ./targets
  ];

  options.stylix = {
    scheme = lib.mkOption {
      type = types.str;
      default = "dracula";
      description = ''
        Base16 color scheme name. Available options are:
        ${toString validSchemes}
      '';
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = builtins.elem cfg.scheme validSchemes;
        message = "Stylix: Invalid colorscheme '${cfg.scheme}'. Available options: ${toString validSchemes}";
      }
    ];

    stylix = {
      autoEnable = mkDefault true;
      base16Scheme = scheme;
      fonts = {
        monospace = mkDefault {
          package = pkgs.hack-font;
          name = "Hack";
        };
      };
      polarity = mkDefault "dark";

      targets = {
        librewolf.profileNames = [ "default" ];
      };
    };

    home.packages = [
      (pkgs.callPackage ./print-colors { })
    ];
  };
}
