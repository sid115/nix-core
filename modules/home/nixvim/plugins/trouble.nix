{ config, lib, ... }:

let
  cfg = config.programs.nixvim;
  plugin = cfg.plugins.trouble;

  inherit (lib) mkDefault;
in
{
  config = {
    programs.nixvim = {
      plugins.trouble = {
        enable = mkDefault true;
        settings = {
          keys = {
            "<leader>td" = "diagnostics toggle";
          };
        };
      };
    };
  };
}
