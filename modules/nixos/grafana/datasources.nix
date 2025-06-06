{ config, ... }:

let
  prometheus = config.services.prometheus;
in
{
  settings.datasources = [
    {
      name = "Prometheus";
      type = "prometheus";
      url = "http://localhost:${toString prometheus.port}";
    }
  ];
}
