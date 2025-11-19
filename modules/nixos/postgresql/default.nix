{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.services.postgresql;
  domain = config.networking.domain;
  fqdn = if (cfg.subdomain != "") then "${cfg.subdomain}.${domain}" else domain;
  inherit (lib)
    mkDefault
    mkIf
    mkOption
    types
    ;
in
{
  options.services.postgresql = {
    subdomain = mkOption {
      type = types.str;
      default = "pgadmin";
      description = "Subdomain for pgAdmin web interface.";
    };
    forceSSL = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to force SSL connections for pgAdmin.";
    };
    enablePGadmin = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable pgAdmin GUI.";
    };
  };

  config = mkIf cfg.enable {
    services.postgresql = {
      #    enableTCPIP = true;   ### I don't know if this is necessary, but seems like
      authentication = pkgs.lib.mkOverride 10 ''
        #type database DBuser auth-method
        local all      all    trust
        # Existing rule for local socket connections (for sudo -u postgres psql)
        local   all         all                 peer
        # NEW RULES for network connections from localhost (for pgAdmin & Co.)
        # This line allows unencrypted connections from 127.0.0.1 (IPv4)
        host    all         all     127.0.0.1/32  md5
        # This line allows unencrypted connections from ::1 (IPv6)
        host    all         all     ::1/128       md5
        # If you only want to allow encrypted connections (better security):
        # hostssl all         all     127.0.0.1/32  md5
        # hostssl all         all     ::1/128       md5
      '';
    };
    #};

    services.pgadmin = mkIf cfg.enablePGadmin {
      enable = true;
      initialEmail = "admin@${config.networkingdomain}";
      initialPasswordFile = config.sops.secrets."pgadmin".path; # ## maybe overkill, need to find a better way
      settings = {
        "MAX_LOGIN_ATTEMPTS" = mkDefault 5; # ## default is 3 usually, if this limit is reached, the pgadmin db needs to be adjusted manually
      };
    };

    services.nginx.virtualHosts."${fqdn}" = {
      enableACME = cfg.forceSSL;
      forceSSL = cfg.forceSSL;
      locations."/" = {
        proxyPass = "http://localhost:5050";
        proxyWebsockets = true;
      };
    };
  };
}
