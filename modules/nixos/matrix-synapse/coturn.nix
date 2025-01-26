{ config, lib, ... }:

let
  _coturn = config.services.coturn;
  _sops = config.sops;
  cfg = config.services.matrix-synapse;

  inherit (lib) mkIf;
in
{
  config = mkIf cfg.enable {
    services.coturn = rec {
      enable = true;
      no-cli = true;
      no-tcp-relay = true;
      min-port = 49000;
      max-port = 50000;
      listening-port = 3478;
      tls-listening-port = 5349;
      use-auth-secret = true;
      static-auth-secret-file = _sops.secrets."coturn/static-auth-secret".path;
      realm = "turn.${config.networking.domain}";
      cert = "${config.security.acme.certs.${realm}.directory}/full.pem";
      pkey = "${config.security.acme.certs.${realm}.directory}/key.pem";
      extraConfig = ''
        # for debugging
        verbose
        # ban private IP ranges
        no-multicast-peers
        denied-peer-ip=0.0.0.0-0.255.255.255
        denied-peer-ip=10.0.0.0-10.255.255.255
        denied-peer-ip=100.64.0.0-100.127.255.255
        denied-peer-ip=127.0.0.0-127.255.255.255
        denied-peer-ip=169.254.0.0-169.254.255.255
        denied-peer-ip=172.16.0.0-172.31.255.255
        denied-peer-ip=192.0.0.0-192.0.0.255
        denied-peer-ip=192.0.2.0-192.0.2.255
        denied-peer-ip=192.88.99.0-192.88.99.255
        denied-peer-ip=192.168.0.0-192.168.255.255
        denied-peer-ip=198.18.0.0-198.19.255.255
        denied-peer-ip=198.51.100.0-198.51.100.255
        denied-peer-ip=203.0.113.0-203.0.113.255
        denied-peer-ip=240.0.0.0-255.255.255.255
        denied-peer-ip=::1
        denied-peer-ip=64:ff9b::-64:ff9b::ffff:ffff
        denied-peer-ip=::ffff:0.0.0.0-::ffff:255.255.255.255
        denied-peer-ip=100::-100::ffff:ffff:ffff:ffff
        denied-peer-ip=2001::-2001:1ff:ffff:ffff:ffff:ffff:ffff:ffff
        denied-peer-ip=2002::-2002:ffff:ffff:ffff:ffff:ffff:ffff:ffff
        denied-peer-ip=fc00::-fdff:ffff:ffff:ffff:ffff:ffff:ffff:ffff
        denied-peer-ip=fe80::-febf:ffff:ffff:ffff:ffff:ffff:ffff:ffff
      '';
    };

    networking.firewall = with _coturn; {
      allowedUDPPortRanges = [
        {
          from = min-port;
          to = max-port;
        }
      ];
      allowedUDPPorts = [
        listening-port
        tls-listening-port
        alt-listening-port
        alt-tls-listening-port
      ];
      allowedTCPPorts = [
        listening-port
        tls-listening-port
        alt-listening-port
        alt-tls-listening-port
      ];
    };

    security.acme.certs.${_coturn.realm} = {
      postRun = "systemctl restart coturn.service";
      group = "turnserver";
    };

    services.matrix-synapse.settings = {
      turn_uris = with _coturn; [
        "turn:${realm}:${toString listening-port}?transport=udp"
        "turn:${realm}:${toString listening-port}?transport=tcp"
        "turn:${realm}:${toString tls-listening-port}?transport=udp"
        "turn:${realm}:${toString tls-listening-port}?transport=tcp"
        "turn:${realm}:${toString alt-listening-port}?transport=udp"
        "turn:${realm}:${toString alt-listening-port}?transport=tcp"
        "turn:${realm}:${toString alt-tls-listening-port}?transport=udp"
        "turn:${realm}:${toString alt-tls-listening-port}?transport=tcp"
      ];
      extraConfigFiles = [ _sops.templates."coturn/static-auth-secret.env".path ];
      turn_user_lifetime = "1h";
    };

    sops = {
      secrets."coturn/static-auth-secret" = {
        owner = "turnserver";
        group = "turnserver";
        mode = "0440";
      };
      templates."coturn/static-auth-secret.env" = {
        content = ''
          static-auth-secret=${_sops.placeholder."coturn/static-auth-secret"}
        '';
        owner = "turnserver";
        group = "turnserver";
        mode = "0440";
      };
    };
  };
}
