# disk
{ lib, ... }:

let
  inherit (lib) mkDefault;
in
{
  interval = mkDefault 3600;
  format = mkDefault " {percentage_used}";
  path = mkDefault "/";
}
