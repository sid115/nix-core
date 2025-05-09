{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Bindet genau dieses eine Dashboard ein
  config.services.grafana.provision.dashboards.settings.providers = [
    {
      name = "single-metric"; # eindeutiger Provider‐Name
      type = "file"; # file‐Provider
      orgId = 1; # Grafana‐Org
      folder = "NixOS"; # Ziel‐Ordner in der UI
      disableDeletion = false; # altes Dashboard bestehen lassen
      editable = true; # im UI änderbar halten
      options = {
        path = ./simple-panel-dashboard.json; # Pfad zur JSON‐Datei
      };
    }
  ];
}
