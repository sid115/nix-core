# Edit this only if you know what you're doing.
{
  networking.hostName = "uvm";

  users.users.root.password = "";
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

  services.openssh = {
    enable = true;
    ports = [ 22 ];
    openFirewall = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
    };
  };
}
