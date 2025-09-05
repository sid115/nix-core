{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.networking.wg-server;

  mkPeer = name: {
    inherit name;
    inherit (cfg.peers.${name}) publicKey presharedKeyFile;
    allowedIPs = [ "${cfg.peers.${name}.allowedIP}/${toString cfg.peerAddressMask}" ];
    persistentKeepalive = mkDefault 25;
  };
  mkPeers = names: map mkPeer names;

  iptables = "${pkgs.iptables}/bin/iptables";

  inherit (lib)
    literalExpression
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in
{
  options.networking.wg-server = {
    enable = mkEnableOption "Enable VPN server";
    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to allow VPN and DNS traffic through the firewall";
    };
    externalInterface = mkOption {
      type = types.str;
      example = "eth0";
      description = "The external network interface for VPN traffic";
    };
    internalInterface = mkOption {
      type = types.str;
      default = "wg0";
      description = "The internal WireGuard interface name";
    };
    port = mkOption {
      type = types.port;
      default = 51820;
      description = "The port number for the VPN server";
    };
    subnetMask = mkOption {
      type = types.ints.u8;
      default = 24;
      description = "The subnet mask for the VPN network";
    };
    serverAddress = mkOption {
      type = types.str;
      default = "10.0.0.1";
      description = "The server's IP address within the VPN subnet";
    };
    peerAddressMask = mkOption {
      type = types.ints.u8;
      default = 32;
      description = "The subnet mask for peer addresses";
    };
    peers = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            publicKey = mkOption {
              type = types.str;
              description = "The public key of the peer";
            };
            presharedKeyFile = mkOption {
              type = types.nullOr types.path;
              default = null;
              description = "Path to the preshared key file for the peer (optional)";
            };
            allowedIP = mkOption {
              type = types.str;
              description = "The IP address assigned to the peer within the VPN subnet";
            };
          };
        }
      );
      default = { };
      description = "VPN peers configuration";
      example = literalExpression ''
        {
          phone = {
            publicKey = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx=";
            allowedIP = "10.100.0.2";
          };
          laptop = {
            publicKey = "yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy=";
            presharedKeyFile = "/path/to/preshared_key"; # optional
            allowedIP = "10.100.0.3";
          };
        }
      '';
    };
  };

  config = mkIf cfg.enable {
    networking = {
      nat = {
        enable = true;
        # enableIPv6 = true; # TODO
        externalInterface = cfg.externalInterface;
        internalInterfaces = [ cfg.internalInterface ];
      };
      firewall = mkIf cfg.openFirewall {
        allowedTCPPorts = [ 53 ];
        allowedUDPPorts = [
          53
          cfg.port
        ];
      };
      wg-quick.interfaces = {
        "${cfg.internalInterface}" = {
          address = [ "${cfg.serverAddress}/${cfg.subnetMask}" ];
          listenPort = cfg.port;
          privateKeyFile = config.sops.secrets."wireguard/private-key".path;
          postUp = ''
            ${iptables} -A FORWARD -i ${cfg.internalInterface} -j ACCEPT
            ${iptables} -t nat -A POSTROUTING -s ${cfg.serverAddress}/${toString cfg.subnetMask} -o ${cfg.externalInterface} -j MASQUERADE
          '';
          preDown = ''
            ${iptables} -D FORWARD -i ${cfg.internalInterface} -j ACCEPT
            ${iptables} -t nat -D POSTROUTING -s ${cfg.serverAddress}/${toString cfg.subnetMask} -o ${cfg.externalInterface} -j MASQUERADE
          '';

          peers = mkPeers (builtins.attrNames cfg.peers);
        };
      };
    };

    services = {
      dnsmasq = {
        enable = mkDefault true;
        settings.interface = cfg.internalInterface;
      };
    };

    sops.secrets."wireguard/private-key" = { };
  };
}
