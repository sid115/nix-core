{
  config,
  lib,
  ...
}:

let
  cfg = config.services.matrix-synapse;
  domain = config.networking.domain;
  keyFile = config.sops.templates."livekit/key".path;

  inherit (lib) mkIf mkDefault;
in
{
  config = mkIf cfg.enable {
    services.livekit = {
      enable = true;
      openFirewall = mkDefault true;
      settings.room.auto_create = mkDefault false;
      inherit keyFile;
      settings.port = mkDefault 7880;
    };

    services.lk-jwt-service = {
      enable = true;
      livekitUrl = "wss://${domain}/livekit/sfu";
      inherit keyFile;
    };

    systemd.services.lk-jwt-service.environment.LIVEKIT_FULL_ACCESS_HOMESERVERS = domain;

    services.nginx.virtualHosts = {
      "${domain}".locations = {
        "^~ /livekit/jwt/" = {
          priority = 400;
          proxyPass = "http://127.0.0.1:${toString config.services.lk-jwt-service.port}/";
        };
        "^~ /livekit/sfu/" = {
          priority = 400;
          proxyPass = "http://127.0.0.1:${toString config.services.livekit.settings.port}/";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_send_timeout 120;
            proxy_read_timeout 120;
            proxy_buffering off;
            proxy_set_header Accept-Encoding gzip;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
          '';
        };
      };
    };

    sops.secrets."livekit/key" = { };
    sops.templates."livekit/key".content = ''
      API Secret:  ${config.sops.placeholder."livekit/key"}
    '';
  };
}
