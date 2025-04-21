{ config, lib, ... }:

let
  cfg = config.programs.nixvim;
  plugin = cfg.plugins.treesitter;

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
          highlight.enable = mkDefault true;
          incremental_selection.enable = mkDefault true;
          indent.enable = mkDefault true;
        };
      };
      plugins.treesitter-textobjects = mkIf plugin.enable { enable = mkDefault true; };
      plugins.treesitter-context = mkIf plugin.enable { enable = mkDefault true; };
    };
  };
}
