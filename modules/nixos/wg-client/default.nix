{
  config,
  lib,
  ...
}:

let
  cfg = config.networking.wg-client;

  inherit (lib)
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in
{
  options.networking.wg-client = {
    enable = mkEnableOption "Enable VPN client";
    internalInterface = mkOption {
      type = types.str;
      default = "wg0";
      description = "The internal WireGuard interface name";
    };
    subnetMask = mkOption {
      type = types.ints.u8;
      default = 24;
      description = "The subnet mask for the VPN network";
    };
    clientAddress = mkOption {
      type = types.str;
      default = "10.0.0.2";
      description = "The client's IP address within the VPN subnet";
    };
    peer = {
      publicKey = mkOption {
        type = types.str;
        description = "The public key of the peer";
      };
      presharedKeyFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = "Path to the preshared key file for the peer";
      };
      publicIP = mkOption {
        type = types.str;
        description = "The public IP address of the VPN server";
      };
      port = mkOption {
        type = types.port;
        default = 51820;
        description = "The port number for the VPN server";
      };
      internalIP = mkOption {
        type = types.str;
        default = "10.0.0.1";
        description = "The internal IP address of the VPN server within the VPN subnet";
      };
    };
  };

  config = mkIf cfg.enable {
    networking.wg-quick.interfaces = {
      ${cfg.internalInterface} = {
        address = [ "${cfg.clientAddress}/${cfg.subnetMask}" ];
        dns = [ cfg.peer.internalIP ];
        privateKeyFile = config.sops.secrets."wireguard/private-key".path;
        peers = [
          {
            publicKey = cfg.peer.publicKey;
            # presharedKeyFile = "/root/wireguard-keys/preshared_from_peer0_key"; # TODO
            allowedIPs = mkDefault [ "0.0.0.0/0" ];
            endpoint = "${cfg.peer.publicIP}:${cfg.peer.port}";
            persistentKeepalive = mkDefault 25;
          }
        ];
      };
    };

    sops.secrets."wireguard/private-key" = { };
  };
}
