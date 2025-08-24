{ config, lib, ... }:

let
  cfg = config.stylix;
  target = cfg.targets.nixvim;

  inherit (lib) mkIf;
in
{
  config = mkIf cfg.enable {
    stylix.targets.nixvim.enable = false;
    programs.nixvim.colorschemes."${cfg.scheme}".enable = !target.enable;
  };
}
