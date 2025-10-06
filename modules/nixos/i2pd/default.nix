# https://voidcruiser.nl/rambles/i2p-on-nixos/
# TODO: HM config for i2p profile in LibreWolf

{ config, lib, ... }:

let
  cfg = config.services.i2pd;

  inherit (lib)
    mkDefault
    mkIf
    mkOption
    optional
    ;
in
{
  options.services.i2pd = {
    openFirewall = mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to open the necessary firewall ports for enabled protocls of i2pd.";
    };
  };

  config = mkIf cfg.enable {
    services.i2pd = {
      address = mkDefault "127.0.0.1";
      proto = {
        http.enable = mkDefault true;
        socksProxy.enable = mkDefault true;
        httpProxy.enable = mkDefault true;
        sam.enable = mkDefault true;
        i2cp.enable = mkDefault true;
      };
    };

    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall (
      with cfg.proto;
      optional bob.enable bob.port
      ++ optional http.enable http.port
      ++ optional httpProxy.enable httpProxy.port
      ++ optional i2cp.enable i2cp.port
      ++ optional i2pControl.enable i2pControl.port
      ++ optional sam.enable sam.port
      ++ optional socksProxy.enable socksProxy.port
    );
  };
}
