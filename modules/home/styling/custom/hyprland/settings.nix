{ config, ... }:

let
  cfg = config.styling;
in
{
  general = {
    gaps_in = cfg.gaps / 2;
    gaps_out = cfg.gaps;
  };
  decoration = {
    rounding = cfg.radius;
  };
}
