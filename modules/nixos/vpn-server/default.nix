# Create a key pair:
# nix-shell -p wireguard-tools --run "wg genkey | tee privkey | wg pubkey > pubkey"
# This will create two files: `privkey` and `pubkey`.

{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.networking.vpn-server;

  mkPeer = name: {
    inherit name;
    inherit (cfg.peers.${name}) publicKey;
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
  options.networking.vpn-server = {
    enable = mkEnableOption "Enable VPN server";
    externalInterface = mkOption {
      type = types.strMatching ".+";
      default = "";
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
    subnet = mkOption {
      type = types.str;
      default = "10.100.0.0";
      description = "The subnet for the VPN network";
    };
    subnetMask = mkOption {
      type = types.ints.u8;
      default = 24;
      description = "The subnet mask for the VPN network";
    };
    serverAddress = mkOption {
      type = types.str;
      default = "10.100.0.1";
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
            allowedIP = "10.100.0.3";
          };
        }
      '';
    };
  };

  config = mkIf cfg.enable {
    assertions =
      let
        optionPrefix = "networking.vpn-server.";
        messagePrefix = "nix-core/nixos/vpn-server:";
      in
      [
        {
          assertion = cfg.internalInterface != cfg.externalInterface;
          message = "${messagePrefix} `${optionPrefix}internalInterface` must not be the same as `${optionPrefix}externalInterface`";
        }
        # TODO: check for IP collisions
        # TODO: make sure every IP is in the same subnet
      ];

    networking = {
      firewall.allowedUDPPorts = [ cfg.port ];

      nat = {
        enable = true;
        externalInterface = cfg.externalInterface;
        internalInterfaces = [ cfg.internalInterface ];
      };

      wireguard = {
        enable = true;
        interfaces = {
          "${cfg.internalInterface}" = {
            ips = [ "${cfg.serverAddress}/${toString cfg.subnetMask}" ];
            listenPort = cfg.port;
            dynamicEndpointRefreshSeconds = mkDefault 300;

            postSetup = ''
              ${iptables} -t nat -A POSTROUTING -s ${cfg.subnet}/${toString cfg.subnetMask} -o ${cfg.externalInterface} -j MASQUERADE
            '';
            postShutdown = ''
              ${iptables} -t nat -D POSTROUTING -s ${cfg.subnet}/${toString cfg.subnetMask} -o ${cfg.externalInterface} -j MASQUERADE
            '';

            privateKeyFile = config.sops.secrets."wireguard/private-key".path;
            generatePrivateKeyFile = false;

            peers = mkPeers (builtins.attrNames cfg.peers);
          };
        };
      };
    };

    sops.secrets."wireguard/private-key" = { };
  };
}
