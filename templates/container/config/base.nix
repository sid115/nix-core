# Edit this only if you know what you're doing.
{ outputs, ... }:

{
  boot = {
    isContainer = true;
    isNspawnContainer = true;
  };

  nix = {
    channel.enable = false;
    settings = {
      experimental-features = "nix-command flakes";
      builders-use-substitutes = true;
      substituters = [
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };

  nixpkgs.overlays = [
    outputs.overlays.core-packages
    outputs.overlays.local-packages
  ];

  system.stateVersion = "25.11";
}
