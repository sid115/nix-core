{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.matrix-synapse;
  domain = config.networking.domain;
  fqdn = domain;
  port = 8008;
  baseUrl = "https://${fqdn}";

  baseClientConfig = {
    "m.homeserver".base_url = baseUrl;
    "m.identity_server".base_url = "https://vector.im";
  };

  livekitConfig = lib.optionalAttrs config.services.livekit.enable {
    "org.matrix.msc3575.proxy".url = baseUrl;
    "org.matrix.msc4143.rtc_foci" = [
      {
        type = "livekit";
        livekit_service_url = baseUrl + "/livekit/jwt";
      }
    ];
  };

  clientConfig = baseClientConfig // livekitConfig;

  serverConfig."m.server" = "${fqdn}:443";

  mkWellKnown = data: ''
    default_type application/json;
    add_header Access-Control-Allow-Origin *;
    return 200 '${builtins.toJSON data}';
  '';

  inherit (lib) mkIf;
in
{
  imports = [
    ./coturn.nix
    ./element-call.nix
  ];

  config = mkIf cfg.enable {

    services.livekit.enable = lib.mkDefault true;

    services.postgresql = {
      enable = true;
      initialScript = pkgs.writeText "synapse-init.sql" ''
        CREATE ROLE "matrix-synapse" WITH LOGIN PASSWORD 'synapse';
        CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse"
          TEMPLATE template0
          LC_COLLATE = 'C'
          LC_CTYPE = 'C';
      '';
    };

    services.matrix-synapse = {
      settings = {
        registration_shared_secret_path = config.sops.secrets."matrix/registration-shared-secret".path;
        server_name = domain;
        public_baseurl = baseUrl;
        listeners = [
          {
            inherit port;
            bind_addresses = [ "127.0.0.1" ];
            resources = [
              {
                compress = true;
                names = [ "client" ];
              }
              {
                compress = false;
                names = [ "federation" ];
              }
            ];
            tls = false;
            type = "http";
            x_forwarded = true;
          }
        ];
      };
    };

    environment.shellAliases = {
      register_new_matrix_user = "${cfg.package}/bin/register_new_matrix_user -k $(sudo cat ${
        config.sops.secrets."matrix/registration-shared-secret".path
      })";
    };

    services.nginx.virtualHosts."${fqdn}" = {
      enableACME = true;
      forceSSL = true;

      locations."= /.well-known/matrix/server".extraConfig = mkWellKnown serverConfig;
      locations."= /.well-known/matrix/client".extraConfig = mkWellKnown clientConfig;

      locations."/_matrix".proxyPass = "http://127.0.0.1:${toString port}";
      locations."/_synapse".proxyPass = "http://127.0.0.1:${toString port}";
    };

    sops.secrets."matrix/registration-shared-secret" = {
      owner = "matrix-synapse";
      group = "matrix-synapse";
      mode = "0440";
    };
  };
}
