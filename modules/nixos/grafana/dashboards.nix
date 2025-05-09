{ config, lib, pkgs, ... }:

# Grafana Dashboard Provisioning Modulfragment (Inline JSON)
let
  # Definiere das Dashboard als Nix-Attrset
  dashboard = {
    title = "System Overview";
    uid   = "system-overview";
    time  = { from = "now-1h"; to = "now"; };
    schemaVersion = 16;
    version       = 1;
    panels = [
      { type = "graph"; title = "CPU Usage (%)";
        datasource = "Prometheus";
        targets = [ { expr = "100 - (avg by (instance) (rate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100)"; legendFormat = "CPU - {{instance}}"; } ];
        gridPos = { h = 6; w = 12; x = 0; y = 0; };
      }
      { type = "graph"; title = "Memory Usage (%)";
        datasource = "Prometheus";
        targets = [ { expr = "(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100"; legendFormat = "Memory"; } ];
        gridPos = { h = 6; w = 12; x = 12; y = 0; };
      }
      { type = "graph"; title = "Disk Usage (%)";
        datasource = "Prometheus";
        targets = [ { expr = "1 - (node_filesystem_avail_bytes{fstype!=\"tmpfs\",fstype!=\"rootfs\"} / node_filesystem_size_bytes{fstype!=\"tmpfs\",fstype!=\"rootfs\"})"; legendFormat = "{{mountpoint}}"; } ];
        gridPos = { h = 6; w = 12; x = 0; y = 6; };
      }
      { type = "graph"; title = "Network Traffic (Bytes/s)";
        datasource = "Prometheus";
        targets = [
          { expr = "rate(node_network_receive_bytes_total[5m])"; legendFormat = "Receive - {{instance}}"; }
          { expr = "rate(node_network_transmit_bytes_total[5m])"; legendFormat = "Transmit - {{instance}}"; }
        ];
        gridPos = { h = 6; w = 12; x = 12; y = 6; };
      }
    ];
  };

  # Schreibe das JSON zur Laufzeit ins Nix-Build-Output
  dashboardJsonFile = pkgs.writeText "system-overview.json" (builtins.toJSON dashboard);
in
{
  config.services.grafana.provision.dashboards.settings.providers = [
    {
      name            = "system-overview";
      type            = "file";
      orgId           = 1;
      folder          = "NixOS";
      disableDeletion = false;
      editable        = true;
      options = {
        # Pfad zum automatisch generierten JSON
        path = dashboardJsonFile;
      };
    }
  ];
}

# Grafana Dashboard Provisioning Modulfragment
# Erzeugt ein System-Overview Dashboard basierend auf Prometheus-Metriken
{
  config.services.grafana.provision.dashboards.settings.providers = [
    {
      # Eindeutiger Name des Dashboard-Providers
      name            = "system-overview";
      # Typ des Providers: lokale JSON-Dateien
      type            = "file";
      # Grafana-Organisation (Standard: 1)
      orgId           = 1;
      # Ziel-Folder in Grafana
      folder          = "NixOS";
      # Altes Dashboard nicht löschen
      disableDeletion = false;
      # Dashboard in der UI editierbar lassen
      editable        = true;
      # Optionen für den file-Provider
      options = {
        # Pfad zur JSON-Definition (erstellt z.B. modules/nixos/grafana/system-overview.json)
        path = ./system-overview.json;
      };
    }
  ];
}

