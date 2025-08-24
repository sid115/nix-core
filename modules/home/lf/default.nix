{
  config,
  lib,
  pkgs,
  ...
}:

# this assumes that kitty is your default terminal emulator

# There is much more to be implemented here:
# https://github.com/gokcehan/lf/wiki/Tips
# https://github.com/gokcehan/lf/wiki/Integrations

let
  cfg = config.programs.lf;
  vidthumb = pkgs.writeShellScriptBin "vidthumb" (builtins.readFile ./vidthumb.sh);

  mkCommand = path: "\${{\n" + builtins.readFile path + "\n}}\n";

  inherit (lib) mkDefault mkIf;
in
{
  config = mkIf config.programs.kitty.enable {
    home.packages =
      with pkgs;
      [
        font-awesome
        jq
        bat
        hexyl
        glow
        chafa
        poppler_utils
        w3m
        ffmpeg
        ffmpegthumbnailer
        trash-cli
        xdg-utils
        perl540Packages.MIMETypes
      ]
      ++ [
        vidthumb
      ];

    programs.lf = {
      commands = {
        bulk-rename = mkCommand ./commands/bulk-rename.sh;
        extract = mkCommand ./commands/extract.sh;
        open = mkCommand ./commands/open.sh;
        paste = mkCommand ./commands/paste.sh;
        trash = "%trash-put -- $fx";
        zip = mkCommand ./commands/zip.sh;
      };
      settings = {
        autoquit = mkDefault true;
        cleaner = mkDefault (config.home.homeDirectory + "/" + config.xdg.configFile."lf/cleaner".target);
        dircache = mkDefault true;
        globsearch = mkDefault true;
        icons = mkDefault true;
        incfilter = mkDefault true;
        number = mkDefault false;
        previewer = mkDefault (
          config.home.homeDirectory + "/" + config.xdg.configFile."lf/previewer".target
        );
        ratios = mkDefault [
          1
          1
          2
        ];
        shell = mkDefault "zsh";
        shellopts = mkDefault "-eu";
        wrapscroll = mkDefault true;
      };
      keybindings = import ./keybindings.nix;
    };

    programs.pistol = mkIf cfg.enable {
      enable = mkDefault true;
      associations = mkDefault [
        {
          fpath = ".*.log$";
          command = "sh: less %pistol-filename%";
        }
        {
          fpath = ".*.md$";
          command = "sh: glow %pistol-filename%";
        }
        {
          fpath = ".*.sh$";
          command = "sh: bat %pistol-filename%";
        }
        {
          mime = "application/json";
          command = "sh: bat %pistol-filename%";
        }
        {
          mime = "application/pdf"; # FIXME
          command = "sh: pdftoppm -png %pistol-filename% -singlefile -scale-to 1024 | chafa";
        }
        {
          mime = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"; # FIXME
          command = "sh: libreoffice --headless --convert-to png %pistol-filename% && chafa %pistol-filename%.png";
        }
        # {
        #   mime = "application/*";
        #   command = "sh: hexyl %pistol-filename%";
        # }
        {
          mime = "audio/*"; # FIXME
          command = "sh: ffmpeg -i %pistol-filename% -f wav -";
        }
        {
          mime = "image/*";
          command = "sh: chafa %pistol-filename%";
        }
        {
          mime = "text/html";
          command = "sh: w3m -dump %pistol-filename%";
        }
        {
          mime = "text/*";
          command = "sh: bat %pistol-filename%";
        }
        {
          mime = "video/*";
          command = "sh: ffmpegthumbnailer -i %pistol-filename% -o - | chafa";
        }
      ];
    };

    xdg.configFile = {
      "lf/icons" = mkDefault {
        enable = true;
        source = ./icons;
      };
      "lf/cleaner" = mkDefault {
        enable = true;
        executable = true;
        source = ./cleaner.sh;
      };
      "lf/previewer" = mkDefault {
        enable = true;
        executable = true;
        source = ./previewer.sh;
      };
    };
  };
}
