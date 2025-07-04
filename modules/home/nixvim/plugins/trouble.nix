{ config, lib, ... }:

let
  cfg = config.programs.nixvim;
  plugin = cfg.plugins.trouble;

  inherit (lib) mkDefault mkIf;
in
{
  config = {
    programs.nixvim = {
      plugins.trouble = {
        enable = mkDefault true;
      };
      keymaps = mkIf plugin.enable [
        {
          mode = "n";
          key = "<leader>xq";
          action = "<CMD>Trouble qflist toggle<CR>";
          options = {
            desc = "Trouble quifick toggle";
          };
        }
        {
          mode = "n";
          key = "<leader>xl";
          action = "<CMD>Trouble loclist toggle<CR>";
          options = {
            desc = "Trouble loclist toggle";
          };
        }
        {
          mode = "n";
          key = "<leader>xx";
          action = "<CMD>Trouble diagnostics toggle<CR>";
          options = {
            desc = "Trouble diagnostics toggle";
          };
        }
      ];
    };
  };
}
