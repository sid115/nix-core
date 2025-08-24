# network
{ lib, ... }:

let
  inherit (lib) mkDefault;
in
{
  interval = mkDefault 10;
  format-wifi = mkDefault " {signalStrength}";
  format-ethernet = mkDefault "";
  format-disconnected = mkDefault ""; # An empty format will hide the module.
  tooltip-format = mkDefault ''
    Interface: {ifname}
    IP Address: {ipaddr}
    Gateway: {gwaddr}
    Netmask: {netmask}
    CIDR: {cidr}
    ESSID: {essid}
    Signal: {signaldBm} dBm / {signalStrength}%
    Frequency: {frequency} GHz
    Bandwidth Up: {bandwidthUpBits} / {bandwidthUpBytes}
    Bandwidth Down: {bandwidthDownBits} / {bandwidthDownBytes}
    Total Bandwidth: {bandwidthTotalBits} / {bandwidthTotalBytes}
    Icon: {icon}
  '';
  tooltip-format-wifi = mkDefault ''
    Interface: {ifname}
    IP Address: {ipaddr}/{cidr}
    Gateway: {gwaddr}
    Netmask: {netmask}
    ESSID: {essid}
    Signal: {signaldBm} dBm / {signalStrength}%
    Frequency: {frequency} GHz
    Bandwidth Up: {bandwidthUpBits} / {bandwidthUpBytes}
    Bandwidth Down: {bandwidthDownBits} / {bandwidthDownBytes}
    Total Bandwidth: {bandwidthTotalBits} / {bandwidthTotalBytes}
  '';
  tooltip-format-ethernet = mkDefault ''
    Interface: {ifname}
    IP Address: {ipaddr}/{cidr}
    Gateway: {gwaddr}
    Netmask: {netmask}
    Bandwidth Up: {bandwidthUpBits} / {bandwidthUpBytes}
    Bandwidth Down: {bandwidthDownBits} / {bandwidthDownBytes}
    Total Bandwidth: {bandwidthTotalBits} / {bandwidthTotalBytes}
  '';
  tooltip-format-disconnected = mkDefault "Disconnected";
}
