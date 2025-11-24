{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.passwordManager;
  passmenuScript = pkgs.writeShellScriptBin "passmenu-bemenu" (builtins.readFile ./passmenu); # TODO: override original passmenu script coming from pass itself
  passff-host = pkgs.passff-host;

  inherit (lib)
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    mkOverride
    types
    ;
in
{
  options.programs.passwordManager = {
    enable = mkEnableOption "password manager using pass, passmenu, and passff.";
    length = mkOption {
      type = types.str;
      default = "20";
      description = "Default length for generated passwords.";
    };
    charset = mkOption {
      type = types.enum [
        "alphanumerical"
        "ascii"
        "custom"
      ];
      default = "alphanumerical";
      description = ''
        Character set for generated passwords. "alphanumerical" and "ascii" will get overwritten by the corresponding charset. Anything else will get parsed as the charset directly.
      '';
    };
    editor = mkOption {
      type = types.str;
      default = "nvim";
      description = "Editor to use for editing passwords. Make sure it is installed on your system.";
    };
    wayland = mkOption {
      type = types.bool;
      default = false;
      description = "If true, bemenu and ydotool will be used instead of dmenu and xdotool.";
    };
    key = mkOption {
      type = types.str;
      default = "";
      description = "GPG key for password store.";
    };
  };

  config = mkIf cfg.enable {
    programs.password-store = {
      enable = true;
      package = pkgs.pass.withExtensions (exts: [ exts.pass-otp ]);
      settings = {
        PASSWORD_STORE_DIR = mkDefault "${config.xdg.dataHome}/password-store";
        PASSWORD_STORE_KEY = mkIf (cfg.key != "") cfg.key;
        PASSWORD_STORE_GENERATED_LENGTH = cfg.length;
        PASSWORD_STORE_CHARACTER_SET =
          if cfg.charset == "alphanumerical" then
            "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
          else if cfg.charset == "ascii" then
            "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+-=[]{}|;:',.<>/?"
          else
            cfg.charset;
        PASSWORD_STORE_ENABLE_EXTENSIONS = "true";
        EDITOR = cfg.editor;
      };
    };

    services.gpg-agent.pinentry.package = mkOverride 1001 pkgs.pinentry-qt; # mkDefault collides with gpg home module

    home.packages = [
      passmenuScript
      pkgs.zbar
    ]
    ++ (
      if cfg.wayland then
        [
          pkgs.bemenu
          pkgs.ydotool
        ]
      else
        [
          pkgs.dmenu
          pkgs.xdotool
        ]
    );

    home.sessionVariables.PASSWORD_STORE_MENU = if cfg.wayland then "bemenu" else "dmenu";

    # FIXME: passff does not autofill OTPs
    programs.librewolf = mkIf config.programs.librewolf.enable {
      package = pkgs.librewolf.override {
        nativeMessagingHosts = [
          passff-host
        ];
        hasMozSystemDirPatch = true;
      };
      nativeMessagingHosts = [ passff-host ];
      profiles.default.extensions.packages =
        with inputs.nur.legacyPackages."${pkgs.system}".repos.rycee.firefox-addons; [ passff ];
    };
  };
}
