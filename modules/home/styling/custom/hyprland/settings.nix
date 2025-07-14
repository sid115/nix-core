{ config, lib, ... }:

let
  cfg = config.styling;
in
{
  general = {
    gaps_in = lib.mkDefault cfg.gaps / 2;
    gaps_out = lib.mkDefault cfg.gaps;
  };
  decoration = {
    rounding = lib.mkDefault cfg.radius;
  };
}
