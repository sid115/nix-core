{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.krdpserver;

  # for generateKeys:
  certFile = "${cfg.certDir}/tls-cert.pem";
  keyFile = "${cfg.certDir}/tls-key.pem";
in
{
  options.services.krdpserver = {
    enable = mkEnableOption "Whether to enable the krdpserver service.";

    package = mkOption {
      type = types.package;
      default = pkgs.kdePackages.krdp;
      description = "The package to use for the krdpserver.";
    };

    generateKeys = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to generate a new TLS certificate and key.";
    };

    certDir = mkOption {
      type = types.str;
      default = "/var/lib/krdpserver";
      description = "The directory to generate a new TLS certificate and key in if generateKeys is true.";
    };

    username = mkOption {
      type = types.str;
      default = "";
      description = "The username to use for login.";
    };

    password = mkOption {
      type = types.str;
      default = "";
      description = "The password to use for login. Requires username to be passed as well.";
    };

    address = mkOption {
      type = types.str;
      default = "0.0.0.0";
      description = "The address to listen on for connections.";
    };

    port = mkOption {
      type = types.int;
      default = 3389;
      description = "The port to use for connections.";
    };

    openPort = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to open the specified port in the firewall.";
    };

    certificate = mkOption {
      type = types.str;
      default = "";
      description = "The TLS certificate file to use.";
    };

    certificateKey = mkOption {
      type = types.str;
      default = "";
      description = "The TLS certificate key to use.";
    };

    monitor = mkOption {
      type = types.nullOr types.int;
      default = null;
      description = "The index of the monitor to use when streaming.";
    };

    virtualMonitor = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Creates a new virtual output to connect to (WIDTHxHEIGHT@SCALE). Incompatible with --monitor.";
    };

    quality = mkOption {
      type = types.int;
      default = 100;
      description = "Encoding quality of the stream, from 0 (lowest) to 100 (highest).";
    };

    plasma = mkOption {
      type = types.bool;
      default = false;
      description = "Use Plasma protocols instead of XDP.";
    };
  };

  config = mkIf cfg.enable {
    # Use activation script to ensure directory and certificates exist
    services.krdpserver.generateKeys = mkIf (cfg.certificate != "" || cfg.certificateKey != "") (
      mkForce false
    ); # Do not generate keys if they are passed.
    system.activationScripts.krdpserver.text = mkIf cfg.generateKeys ''
      mkdir -p ${cfg.certDir}
      if [ ! -f ${certFile} ] || [ ! -f ${keyFile} ]; then
        echo "Generating TLS certificate and key for krdpserver..."
        ${pkgs.openssl}/bin/openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
          -keyout ${keyFile} -out ${certFile} \
          -subj "/C=US/ST=State/L=Locality/O=Organization/CN=localhost"
        chown -R root:root ${cfg.certDir}
        chmod 0600 ${certFile} ${keyFile}
      fi
    '';

    environment.systemPackages = with pkgs; [
      qt6.full
      kdePackages.wayland
      xorg.libxcb
      xorg.xcbutil
      xorg.xcbutilkeysyms
      xorg.xcbutilrenderutil
      xorg.xcbutilwm
      libxkbcommon
    ];

    systemd.services.krdpserver = {
      description = "KRDP Remote Desktop Service";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        Environment = ''
          QT_QPA_PLATFORM=wayland
          XDG_RUNTIME_DIR=/run/user/1000
        '';
        ExecStart = ''
          ${cfg.package}/bin/krdpserver \
            ${optionalString (cfg.username != "") "--username ${cfg.username}"} \
            ${optionalString (cfg.password != "") "--password ${cfg.password}"} \
            --address ${cfg.address} \
            --port ${toString cfg.port} \
            ${optionalString (cfg.certificate != "") "--certificate ${cfg.certificate}"} \
            ${optionalString (cfg.certificateKey != "") "--certificate-key ${cfg.certificateKey}"} \
            ${optionalString cfg.generateKeys "--certificate ${certFile}"} \
            ${optionalString cfg.generateKeys "--certificate-key ${keyFile}"} \
            ${optionalString (cfg.monitor != null) "--monitor ${toString cfg.monitor}"} \
            ${optionalString (cfg.virtualMonitor != null) "--virtual-monitor ${cfg.virtualMonitor}"} \
            --quality ${toString cfg.quality} \
            ${optionalString cfg.plasma "--plasma"} \
            --platform wayland
        '';
        Restart = "always";
      };
      enable = cfg.enable;
    };

    networking.firewall.allowedUDPPorts = mkIf cfg.openPort [ cfg.port ];
    networking.firewall.allowedTCPPorts = mkIf cfg.openPort [ cfg.port ];
  };
}
