{ config, lib, ... }:

let
  cfg = config.programs.nixvim;
  plugin = cfg.plugins.lualine;

  inherit (lib) mkDefault;
in
{
  config = {
    programs.nixvim = {
      plugins.lualine = {
        enable = mkDefault true;
        settings.options.icons_enabled = mkDefault false;
      };
    };
  };
}
