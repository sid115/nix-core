{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.nixvim;
  plugin = cfg.plugins.telescope;

  inherit (lib) mkDefault mkIf;
in
{
  config = {
    programs.nixvim = {
      plugins.telescope = {
        enable = mkDefault true;
        extensions = {
          file-browser.enable = mkDefault true;
          fzf-native.enable = mkDefault true;
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
          "<C-f>" = "live_grep";
        };
      };
    };

    home.packages = mkIf plugin.enable [
      pkgs.ripgrep # for "live_grep"
    ];
  };
}
