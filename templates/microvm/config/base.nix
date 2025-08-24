# Edit this only if you know what you're doing.
{ inputs, outputs, ... }:

{
  imports = [
    inputs.microvm.nixosModules.microvm
  ];

  networking.hostName = "uvm";

  users.users.root = {
    password = "";
  };
  services.getty.autologinUser = "root";

  microvm = {
    volumes = [
      {
        mountPoint = "/var";
        image = "var.img";
        size = 256;
      }
    ];
    shares = [
      {
        proto = "9p";
        tag = "ro-store";
        source = "/nix/store";
        mountPoint = "/nix/.ro-store";
      }
    ];
    interfaces = [
      {
        type = "user";
        id = "qemu";
        mac = "02:00:00:00:00:01";
      }
    ];
    forwardPorts = [
      {
        host.port = 2222;
        guest.port = 22;
      }
    ];
    optimize.enable = true;
    hypervisor = "qemu";
    socket = "control.socket";
  };

  nix = {
    channel.enable = false;
    settings = {
      experimental-features = "nix-command flakes";
      builders-use-substitutes = true;
      substituters = [
        "https://nix-community.cachix.org"
        "https://microvm.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "microvm.cachix.org-1:oXnBc6hRE3eX5rSYdRyMYXnfzcCxC7yKPTbZXALsqys="
      ];
    };
  };

  nixpkgs.overlays = [
    outputs.overlays.core-packages
    outputs.overlays.local-packages
  ];

  services.openssh = {
    enable = true;
    ports = [ 22 ];
    openFirewall = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = false;
    };
  };

  system.stateVersion = "25.11";
}
