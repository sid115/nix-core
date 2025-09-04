# battery
{ lib, ... }:

let
  inherit (lib) mkDefault;
in
{
  interval = mkDefault 10;
  states = {
    warning = mkDefault 20;
    critical = mkDefault 10;
  };
  format = mkDefault "{icon} {capacity}";
  format-icons = mkDefault [
    ""
    ""
    ""
    ""
    ""
  ];
  tooltip-format = mkDefault ''
    {timeTo}
    Capacity:      {capacity}%
    Power Draw:    {power} W
    Charge Cycles: {cycles}
    Health:        {health}%
  '';
}
