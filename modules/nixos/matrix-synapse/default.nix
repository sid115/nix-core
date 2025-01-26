{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.matrix-synapse;
  fqdn = "${config.networking.domain}";
  port = 8008; # add a custom option for this?
  baseUrl = "https://${fqdn}";
  clientConfig."m.homeserver".base_url = baseUrl;
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
    ./bridges
    ./coturn.nix
  ];

  config = mkIf cfg.enable {
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
        server_name = config.networking.domain;
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
      locations."/_matrix".proxyPass = "http://localhost:${toString port}";
      locations."/_synapse/client".proxyPass = "http://localhost:${toString port}";
    };

    sops = {
      secrets."matrix/registration-shared-secret" = {
        owner = "matrix-synapse";
        group = "matrix-synapse";
        mode = "0440";
      };
    };
  };
}
