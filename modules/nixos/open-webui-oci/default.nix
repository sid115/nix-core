{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.open-webui-oci;
  searx = config.services.searx; # TODO: searx web search integration
  domain = config.networking.domain;
  fqdn = if (cfg.subdomain != "") then "${cfg.subdomain}.${domain}" else domain;

  inherit (lib)
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in
{
  options.services.open-webui-oci = {
    enable = mkEnableOption "Enable Open WebUI container with Podman.";
    enableSignUp = mkOption {
      type = types.bool;
      default = false;
      description = "Enable user sign up.";
    };
    port = lib.mkOption {
      type = types.port;
      default = 8080;
      description = "Which port the Open-WebUI server listens to.";
    };
    reverseProxy = mkOption {
      type = types.submodule {
        options = {
          enable = mkEnableOption "Enable Nginx reverse proxy for Open WebUI." // {
            enable = false;
          };
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
        default = { };
        description = "Nginx reverse proxy configuration for Open WebUI.";
        example = {
          enable = true;
          subdomain = "oi";
          forceSSL = true;
        };
      };
    };
  };

  config = mkIf cfg.enable {
    services.nginx.virtualHosts."${fqdn}" = {
      enableACME = cfg.forceSSL;
      forceSSL = cfg.forceSSL;
      locations."/" = {
        proxyPass = mkDefault "http://localhost:${toString cfg.port}";
        proxyWebsockets = true;
      };
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
      image = "localhost/ghcr.io/open-webui/open-webui:main";
      environment = {
        "ANONYMIZED_TELEMETRY" = mkDefault "False";
        "BYPASS_MODEL_ACCESS_CONTROL" = mkDefault "True";
        "DEFAULT_USER_ROLE" = mkDefault "user";
        "DO_NOT_TRACK" = mkDefault "True";
        "ENABLE_SIGNUP" = cfg.enableSignUp;
        "SCARF_NO_ANALYTICS" = mkDefault "True";
        # TODO: More environment variables necessary? Maybe for searx integration? Or should we rely on admin config in the web interface?
      };
      volumes = [
        "open-webui_open-webui:/app/backend/data:rw"
      ];
      ports = [
        "${toString cfg.port}:8080/tcp"
      ];
      log-driver = "journald";
      extraOptions = [
        "--add-host=host.docker.internal:host-gateway"
        "--network-alias=open-webui"
        "--network=open-webui_default"
      ];
    };
    systemd.services."podman-open-webui" = {
      serviceConfig = {
        Restart = lib.mkOverride 90 "always";
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

    systemd.services."podman-build-open-webui" = {
      path = [
        pkgs.podman
        pkgs.git
      ];
      serviceConfig = {
        Type = "oneshot";
        TimeoutSec = 300;
      };
      script = ''
        cd /home/sid/src/open-webui
        podman build -t ghcr.io/open-webui/open-webui:main .
      '';
    };

    systemd.targets."podman-compose-open-webui-root" = {
      unitConfig = {
        Description = "Root target generated by compose2nix.";
      };
      wantedBy = [ "multi-user.target" ];
    };
  };
}
