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
        (pkgs.writeShellScriptBin "vidthumb" builtins.readFile ./vidthumb.sh)
      ];

    programs.lf = {
      commands = {
        bulk-rename = builtins.readFile ./commands/bulk-rename.sh;
        extract = builtins.readFile ./commands/extract.sh;
        open = builtins.readFile ./commands/open.sh;
        paste = builtins.readFile ./commands/paste.sh;
        trash = "%trash-put -- $fx";
        zip = builtins.readFile ./commands/zip.sh;
      };
      settings = {
        autoquit = mkDefault true;
        cleaner = ./cleaner.sh;
        dircache = mkDefault true;
        globsearch = mkDefault true;
        icons = mkDefault true;
        incfilter = mkDefault true;
        number = mkDefault false;
        previewer = ./previewer.sh;
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
          command = "less %pistol-filename%";
        }
        {
          fpath = ".*.md$";
          command = "sh: glow %pistol-filename% | head -8";
        }
        {
          fpath = ".*.sh$";
          command = "bat %pistol-filename%";
        }
        {
          mime = "application/json";
          command = "bat %pistol-filename%";
        }
        {
          mime = "application/pdf";
          command = "pdftoppm -png %pistol-filename% -singlefile -scale-to 1024 | chafa";
        }
        {
          mime = "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
          command = "libreoffice --headless --convert-to png %pistol-filename% && chafa %pistol-filename%.png";
        }
        # {
        #   mime = "application/*";
        #   command = "hexyl %pistol-filename%";
        # }
        {
          mime = "audio/*";
          command = "ffmpeg -i %pistol-filename% -f wav -";
        }
        {
          mime = "image/*";
          command = "chafa %pistol-filename%";
        }
        {
          mime = "text/html";
          command = "w3m -dump %pistol-filename%";
        }
        {
          mime = "text/*";
          command = "bat %pistol-filename%";
        }
        {
          mime = "video/*";
          command = "ffmpegthumbnailer -i %pistol-filename% -o - | chafa";
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
        source = ./cleaner;
      };
      "lf/previewer" = mkDefault {
        enable = true;
        executable = true;
        source = ./previewer;
      };
    };
  };
}
