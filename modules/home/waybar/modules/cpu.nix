# cpu
{ lib, ... }:

let
  inherit (lib) mkDefault;
in
{
  interval = mkDefault 10;
  format = mkDefault " {usage}";
  tooltip-format = mkDefault ''
    CPU Load: {load}
    CPU Usage: {usage}%
    Core 0 Usage: {usage0}%
    Core 1 Usage: {usage1}%
    Core 2 Usage: {usage2}%
    Core 3 Usage: {usage3}%
    Core 4 Usage: {usage4}%
    Core 5 Usage: {usage5}%
    Core 6 Usage: {usage6}%
    Core 7 Usage: {usage7}%
    Average Frequency: {avg_frequency} GHz
    Max Frequency: {max_frequency} GHz
    Min Frequency: {min_frequency} GHz
  '';
}
