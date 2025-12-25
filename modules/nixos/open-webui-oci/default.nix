{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.open-webui-oci;
  domain = config.networking.domain;
  subdomain = cfg.reverseProxy.subdomain;
  fqdn = if (cfg.reverseProxy.enable && subdomain != "") then "${subdomain}.${domain}" else domain;

  defaultEnv = {
    ANONYMIZED_TELEMETRY = "False";
    BYPASS_MODEL_ACCESS_CONTROL = "True";
    DEFAULT_LOCALE = "en";
    DEFAULT_USER_ROLE = "user";
    DO_NOT_TRACK = "True";
    ENABLE_DIRECT_CONNECTIONS = "True";
    ENABLE_IMAGE_GENERATION = "True";
    ENABLE_PERSISTENT_CONFIG = "False";
    ENABLE_SIGNUP = "False";
    ENABLE_SIGNUP_PASSWORD_CONFIRMATION = "True";
    ENABLE_USER_WEBHOOKS = "True";
    ENABLE_WEBSEARCH = "True";
    ENV = "prod";
    SCARF_NO_ANALYTICS = "True";
    USER_AGENT = "OpenWebUI";
    USER_PERMISSIONS_FEATURES_DIRECT_TOOL_SERVERS = "True";
    WEB_SEARCH_ENGINE = "DuckDuckGo";
  };

  baseUrl =
    if cfg.reverseProxy.enable then
      (if cfg.reverseProxy.forceSSL then "https://${fqdn}" else "http://${fqdn}")
    else
      "http://${fqdn}:${toString cfg.port}";

  inherit (lib)
    concatStringsSep
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    mkOverride
    optional
    types
    ;
in
{
  options.services.open-webui-oci = {
    enable = mkEnableOption "Open WebUI container with Podman.";
    port = mkOption {
      type = types.port;
      default = 3000;
      description = "Which port the Open-WebUI server listens to.";
    };
    environment = mkOption {
      default = { };
      type = types.attrsOf types.str;
      description = ''
        Extra environment variables for Open-WebUI.
        For more details see <https://docs.openwebui.com/getting-started/advanced-topics/env-configuration/>
      '';
    };
    environmentFile = mkOption {
      description = "Environment file to be passed to the Open WebUI container.";
      type = types.nullOr types.path;
      default = null;
      example = "config.sops.templates.open-webui-env.path";
    };
    reverseProxy = {
      enable = mkEnableOption "Nginx reverse proxy for Open WebUI.";
      subdomain = mkOption {
        type = types.str;
        default = "ai";
        description = "Subdomain for Nginx virtual host. Leave empty for root domain.";
      };
      forceSSL = mkOption {
        type = types.bool;
        default = true;
        description = "Force SSL for Nginx virtual host.";
      };
    };
  };

  config = mkIf cfg.enable {
    services.nginx.virtualHosts."${fqdn}" = mkIf cfg.reverseProxy.enable {
      enableACME = cfg.reverseProxy.forceSSL;
      forceSSL = cfg.reverseProxy.forceSSL;
      locations."/" = {
        proxyPass = mkDefault "http://127.0.0.1:${toString cfg.port}";
        proxyWebsockets = true;
      };
      sslCertificate = mkIf cfg.reverseProxy.forceSSL "${
        config.security.acme.certs."${fqdn}".directory
      }/cert.pem";
      sslCertificateKey = mkIf cfg.reverseProxy.forceSSL "${
        config.security.acme.certs."${fqdn}".directory
      }/key.pem";
    };

    virtualisation.podman = {
      enable = true;
      autoPrune.enable = true;
      dockerCompat = true;
    };

    networking.firewall.interfaces =
      let
        matchAll = if !config.networking.nftables.enable then "podman+" else "podman*";
      in
      {
        "${matchAll}".allowedUDPPorts = [ 53 ];
      };

    virtualisation.oci-containers.backend = "podman";

    virtualisation.oci-containers.containers."open-webui" = {
      image = "ghcr.io/open-webui/open-webui:main";
      environment =
        defaultEnv
        // cfg.environment
        // {
          PORT = "${toString cfg.port}";
          CORS_ALLOW_ORIGIN = concatStringsSep ";" [
            baseUrl
            "http://localhost:${toString cfg.port}"
            "http://127.0.0.1:${toString cfg.port}"
            "http://0.0.0.0:${toString cfg.port}"
          ];
        };
      environmentFiles = optional (cfg.environmentFile != null) cfg.environmentFile;
      volumes = [
        "open-webui_open-webui:/app/backend/data:rw"
      ];
      log-driver = "journald";
      extraOptions = [
        "--network=host"
      ];
    };
    systemd.services."podman-open-webui" = {
      serviceConfig = {
        Restart = mkOverride 90 "always";
      };
      after = [
        "podman-network-open-webui_default.service"
        "podman-volume-open-webui_open-webui.service"
      ];
      requires = [
        "podman-network-open-webui_default.service"
        "podman-volume-open-webui_open-webui.service"
      ];
      partOf = [
        "podman-compose-open-webui-root.target"
      ];
      wantedBy = [
        "podman-compose-open-webui-root.target"
      ];
    };

    systemd.services."podman-network-open-webui_default" = {
      path = [ pkgs.podman ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStop = "podman network rm -f open-webui_default";
      };
      script = ''
        podman network inspect open-webui_default || podman network create open-webui_default
      '';
      partOf = [ "podman-compose-open-webui-root.target" ];
      wantedBy = [ "podman-compose-open-webui-root.target" ];
    };

    systemd.services."podman-volume-open-webui_open-webui" = {
      path = [ pkgs.podman ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        podman volume inspect open-webui_open-webui || podman volume create open-webui_open-webui
      '';
      partOf = [ "podman-compose-open-webui-root.target" ];
      wantedBy = [ "podman-compose-open-webui-root.target" ];
    };

    systemd.targets."podman-compose-open-webui-root" = {
      unitConfig = {
        Description = "Root target generated by compose2nix.";
      };
      wantedBy = [ "multi-user.target" ];
    };
  };
}
