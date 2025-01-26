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
        settings.ensure_installed = mkDefault "all";
        nixvimInjections = mkDefault true;
        settings = {
          highlight.enable = true;
          incremental_selection.enable = true;
          indent.enable = true;
        };
      };
      plugins.treesitter-textobjects = mkIf plugin.enable { enable = mkDefault true; };
      plugins.treesitter-context = mkIf plugin.enable { enable = mkDefault true; };
    };
  };
}
