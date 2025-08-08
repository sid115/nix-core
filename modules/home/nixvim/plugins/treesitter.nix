{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.nixvim;
  plugin = cfg.plugins.treesitter;

  cc = "${pkgs.gcc}/bin/gcc";

  inherit (lib) mkDefault mkIf;
in
{
  config = {
    programs.nixvim = {
      plugins.treesitter = {
        enable = mkDefault true;
        nixvimInjections = mkDefault true;
        settings = {
          auto_install = mkDefault true;
          ensure_installed = mkDefault "all";
          ignore_install = [
            "ipkg" # upstream is gone
          ];
          highlight.enable = mkDefault true;
          incremental_selection.enable = mkDefault true;
          indent.enable = mkDefault true;
        };
      };
      plugins.treesitter-context = mkIf plugin.enable { enable = mkDefault true; };
      plugins.treesitter-refactor = mkIf plugin.enable { enable = mkDefault true; };
      plugins.treesitter-textobjects = mkIf plugin.enable { enable = mkDefault true; };
    };

    # Fix for: ERROR `cc` executable not found.
    home.sessionVariables = mkIf plugin.enable {
      CC = mkDefault cc;
    };

    # Fix for: WARNING `tree-sitter` executable not found
    # home.packages = mkIf plugin.enable [
    #   pkgs.tree-sitter
    # ];
  };
}
