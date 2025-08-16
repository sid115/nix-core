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
    Signal Strength: {signalStrength}%
    Signal dBm: {signaldBm} dBm
    Frequency: {frequency} GHz
    Bandwidth Up: {bandwidthUpBits} bps / {bandwidthUpBytes} Bps
    Bandwidth Down: {bandwidthDownBits} bps / {bandwidthDownBytes} Bps
    Total Bandwidth: {bandwidthTotalBits} bps / {bandwidthTotalBytes} Bps
    Icon: {icon}
  '';
  tooltip-format-wifi = mkDefault ''
    Interface: {ifname}
    IP Address: {ipaddr}/{cidr}
    Gateway: {gwaddr}
    Netmask: {netmask}
    ESSID: {essid}
    Signal Strength: {signalStrength}%
    Signal dBm: {signaldBm} dBm
    Frequency: {frequency} GHz
    Bandwidth Up: {bandwidthUpBits} bps / {bandwidthUpBytes} Bps
    Bandwidth Down: {bandwidthDownBits} bps / {bandwidthDownBytes} Bps
    Total Bandwidth: {bandwidthTotalBits} bps / {bandwidthTotalBytes} Bps
  '';
  tooltip-format-ethernet = mkDefault ''
    Interface: {ifname}
    IP Address: {ipaddr}/{cidr}
    Gateway: {gwaddr}
    Netmask: {netmask}
    Bandwidth Up: {bandwidthUpBits} bps / {bandwidthUpBytes} Bps
    Bandwidth Down: {bandwidthDownBits} bps / {bandwidthDownBytes} Bps
    Total Bandwidth: {bandwidthTotalBits} bps / {bandwidthTotalBytes} Bps
  '';
  tooltip-format-disconnected = mkDefault "Disconnected";
}
