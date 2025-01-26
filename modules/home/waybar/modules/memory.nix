# memory
{ lib, ... }:

let
  inherit (lib) mkDefault;
in
{
  interval = mkDefault 10;
  format = mkDefault " {percentage}";
  tooltip-format = mkDefault ''
    Total Memory: {total} GiB
    Used Memory: {used} GiB ({percentage}%)
    Available Memory: {avail} GiB
    Total Swap: {swapTotal} GiB
    Used Swap: {swapUsed} GiB ({swapPercentage}%)
    Available Swap: {swapAvail} GiB
  '';
}
