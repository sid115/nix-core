{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Registriere genau diesen einen Provider
  config.services.grafana.provision.dashboards.settings.providers = [
    {
      name = "single-metric"; # eindeutiger Name
      type = "file"; # file-Provider
      orgId = 1; # Grafana-Org
      folder = "NixOS"; # UI-Folder
      disableDeletion = false; # altes Dashboard beibehalten
      editable = true; # im UI editierbar
      options = {
        path = ./simple-panel-dashboard.json; # unser JSON
      };
    }
  ];
}
