{
  config,
  lib,
  pkgs,
  ...
}:

{
  config.services.grafana.provision.dashboards.settings.providers = [
    {
      name = "single-metric";
      type = "file";
      orgId = 1;
      folder = "NixOS";
      disableDeletion = false;
      editable = true;
      options = {
        path = ./simple-panel-dashboard.json;
      };
    }
  ];
}
