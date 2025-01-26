# bluetooth
{ lib, ... }:

let
  inherit (lib) mkDefault;
in
{
  format = mkDefault " {status}";
  format-connected = mkDefault " {device_alias}";
  format-connected-battery = mkDefault " {device_alias} {device_battery_percentage}%";
  format-disabled = mkDefault "";
  format-off = mkDefault "";
  format-on = mkDefault "";
  max-length = mkDefault 12;
  on-click = "bluetoothctl power off";
  tooltip-format = mkDefault "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
  tooltip-format-connected = mkDefault "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
  tooltip-format-enumerate-connected = mkDefault "{device_alias}\t{device_address}";
  tooltip-format-enumerate-connected-battery = mkDefault "{device_alias}\t{device_address}\t{device_battery_percentage}%";
}
