{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.nixvim;
  plugin = cfg.plugins.telescope;

  inherit (lib) mkDefault optionals;
in
{
  config = {
    programs.nixvim = {
      plugins.telescope = {
        enable = mkDefault true;
        extensions = {
          file-browser.enable = mkDefault true;
          fzf-native.enable = mkDefault true;
          live-grep-args.enable = mkDefault true;
          manix.enable = mkDefault true;
        };
        keymaps = mkDefault {
          "<space>fb" = "file_browser";
          "<C-e>" = "file_browser";
          "<leader>ff" = "find_files";
          "<leader>fg" = "live_grep";
          "<leader>bl" = "buffers";
          "<leader>fh" = "help_tags";
          "<leader>fd" = "diagnostics";
          "<C-p>" = "git_files";
          "<leader>fo" = "oldfiles";
        };
      };
      keymaps = optionals plugin.enable [
        {
          key = "<C-f>";
          action = ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>";
          mode = "n";
        }
      ];
    };

    home.packages = optionals plugin.enable [
      pkgs.ripgrep # for "live_grep"
    ];
  };
}
