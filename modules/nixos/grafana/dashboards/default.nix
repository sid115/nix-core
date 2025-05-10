{
  settings.providers = [
    {
      name = "single-metric";
      type = "file";
      orgId = 1;
      folder = "NixOS";
      disableDeletion = false;
      editable = true;
      options = {
        path = ./htop-comparison.json;
      };
    }
  ];
}
