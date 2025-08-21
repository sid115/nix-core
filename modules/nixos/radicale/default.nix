{
  config,
  lib,
  pkgs,
  ...
}:

# Generate passwords with:
# openssl passwd -6 "password"

let
  cfg = config.services.radicale;
  domain = config.networking.domain;
  fqdn = if (cfg.subdomain != "") then "${cfg.subdomain}.${domain}" else domain;
  port = "5232";

  inherit (lib)
    concatLines
    mkDefault
    mkIf
    mkOption
    types
    ;
in
{
  options.services.radicale = {
    users = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [
        "alice"
        "bob"
      ];
      description = "List of users for Radicale. Each user must have a corresponding entry in the SOPS file under 'radicale/<user>'";
    };
    subdomain = mkOption {
      type = types.str;
      default = "dav";
      description = "Subdomain for Nginx virtual host. Leave empty for root domain.";
    };
    forceSSL = mkOption {
      type = types.bool;
      default = true;
      description = "Force SSL for Nginx virtual host.";
    };
  };

  config = mkIf cfg.enable {
    services.radicale = {
      settings = {
        server = {
          hosts = [
            "127.0.0.1:${port}"
          ];
          max_connections = mkDefault 20;
          max_content_length = mkDefault 500000000;
          timeout = mkDefault 30;
        };
        auth = {
          type = "htpasswd";
          delay = mkDefault 1;
          htpasswd_filename = config.sops.templates."radicale/users".path;
          htpasswd_encryption = mkDefault "sha512";
        };
        storage = {
          filesystem_folder = mkDefault "/var/lib/radicale/collections";
        };
      };
    };

    services.nginx.virtualHosts."${fqdn}" = {
      locations."/".proxyPass = "http://127.0.0.1:${port}";
      forceSSL = cfg.forceSSL;
      enableACME = cfg.forceSSL;
    };

    sops =
      let
        owner = "radicale";
        group = "radicale";
        mode = "0440";

        mkSecrets =
          users:
          builtins.listToAttrs (
            map (user: {
              name = "radicale/${user}";
              value = { inherit owner group mode; };
            }) users
          );

        mkTemplate = users: {
          inherit owner group mode;
          content = concatLines (map (user: "${user}:${config.sops.placeholder."radicale/${user}"}") users);
        };
      in
      {
        secrets = mkSecrets cfg.users;
        templates."radicale/users" = mkTemplate cfg.users;
      };

    environment.systemPackages = [
      pkgs.openssl
    ];
  };
}
