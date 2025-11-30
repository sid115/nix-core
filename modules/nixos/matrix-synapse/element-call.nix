{
  config,
  pkgs,
  lib,
  ...
}:

let
  domain = config.networking.domain;
  cfg = config.services.livekit;
  keyFile = config.sops.templates."livekit/keyfile".path;

  callConfig = {
    default_server_config = {
      "m.homeserver" = {
        base_url = "https://${domain}";
        server_name = domain;
      };
    };
    livekit = {
      livekit_service_url = config.services.lk-jwt-service.livekitUrl;
    };
    features = {
      feature_use_device_session_member_events = true;
    };
    ssla = "https://static.element.io/legal/element-software-and-services-license-agreement-uk-1.pdf";
    matrix_rtc_session = {
      wait_for_key_rotation_ms = 3000;
      membership_event_expiry_ms = 180000000;
      delayed_leave_event_delay_ms = 18000;
      delayed_leave_event_restart_ms = 4000;
      network_error_retry_ms = 100;
    };
  };
in
{
  options.services.livekit = {
    apiKey = lib.mkOption {
      type = lib.types.str;
      description = "The public API Key for LiveKit (starts with API...)";
    };
  };

  config = lib.mkIf cfg.enable {
    services.livekit = {
      openFirewall = true;
      settings.room.auto_create = false;
      inherit keyFile;
      settings.port = 7880;
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

      "call.${domain}" = {
        enableACME = true;
        forceSSL = true;
        root = pkgs.element-call;
        locations."/" = {
          extraConfig = "try_files $uri /$uri /index.html;";
        };
        locations."/public/config.json" = {
          extraConfig = ''
            add_header Cache-Control "no-cache, must-revalidate";
            default_type application/json;
            return 200 '${builtins.toJSON callConfig}';
          '';
        };
      };
    };

    sops.secrets."livekit/key" = {
      owner = "root";
    };

    sops.templates."livekit/keyfile" = {
      content = ''
        ${cfg.apiKey}: ${config.sops.placeholder."livekit/key"}
      '';
      mode = "0444";
    };

    #sops.secrets.livekit_secret = {
    #  owner = "root";
    #};

    #sops.templates."livekit/key" = {
    #  content = ''
    #    ${cfg.apiKey}: ${config.sops.placeholder.livekit_secret}
    #  '';
    #  mode = "0444";
    #};
  };
}
