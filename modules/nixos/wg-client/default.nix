# TODO: Handle endpoints behind DynDNS
# https://wiki.archlinux.org/title/WireGuard#Endpoint_with_changing_IP

# TODO: NetworkManager support

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
    mapAttrs
    mapAttrs'
    ;

  wgClientInterface = types.submodule (
    { name, ... }:
    {
      options = {
        internalInterface = mkOption {
          type = types.str;
          default = name;
          description = "The internal WireGuard interface name (defaults to attribute name)";
        };
        subnetMask = mkOption {
          type = types.ints.u8;
          default = 24;
          description = "The subnet mask for the VPN network";
        };
        clientAddress = mkOption {
          type = types.str;
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
    }
  );
in
{
  options.networking.wg-client = {
    enable = mkEnableOption "Enable VPN clients";
    interfaces = mkOption {
      type = types.attrsOf wgClientInterface;
      default = { };
      description = "A set of named WireGuard interfaces";
    };
  };

  config = mkIf cfg.enable {
    networking.wg-quick.interfaces = mapAttrs (name: ifaceCfg: {
      address = [ "${ifaceCfg.clientAddress}/${toString ifaceCfg.subnetMask}" ];
      dns = [ ifaceCfg.peer.internalIP ];
      privateKeyFile = config.sops.secrets."wireguard/${name}/private-key".path;
      peers = [
        {
          inherit (ifaceCfg.peer) publicKey presharedKeyFile;
          allowedIPs = mkDefault [ "0.0.0.0/0" ];
          endpoint = "${ifaceCfg.peer.publicIP}:${toString ifaceCfg.peer.port}";
          persistentKeepalive = mkDefault 25;
        }
      ];
    }) cfg.interfaces;

    sops.secrets = mapAttrs' (name: _: {
      name = "wireguard/${name}/private-key";
      value = { };
    }) cfg.interfaces;
  };
}
