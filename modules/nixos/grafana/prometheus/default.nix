{ config, lib, ... }:

let
  cfg = config.services.prometheus;

  inherit (lib) mkDefault mkIf;
in
{
  config = mkIf config.services.grafana.enable {
    services.prometheus = {
      enable = mkDefault true;
      exporters.node = {
        enable = true;
        port = mkDefault 9009;
        enabledCollectors = [ "systemd" ];
        extraFlags = [
          "--collector.ethtool"
          "--collector.softirqs"
          "--collector.tcpstat"
          "--collector.wifi"
        ];
      };
      scrapeConfigs = [
        {
          job_name = "node";
          static_configs = [
            {
              targets = [
                "127.0.0.1:${toString cfg.exporters.node.port}"
              ];
            }
          ];
        }
      ];
    };
  };
}
