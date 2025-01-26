{ config, lib, ... }:

let
  cfg = config.programs.nixvim;
  plugin = cfg.plugins.trouble;
in
{
  config = {
    programs.nixvim = {
      plugins.trouble = {
        enable = lib.mkDefault true;
      };
    };
  };
}
