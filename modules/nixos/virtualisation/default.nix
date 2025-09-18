{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.virtualisation;

  boolToZeroOne = x: if x then "1" else "0";

  aclString = strings.concatMapStringsSep ''
    ,
  '' strings.escapeNixString cfg.libvirtd.deviceACL;

  inherit (lib)
    mkDefault
    mkOption
    optionals
    strings
    types
    ;
in
{
  imports = [
    ./hugepages.nix
    ./kvmfr.nix
    ./vfio.nix
  ];

  options.virtualisation = {
    libvirtd = {
      deviceACL = mkOption {
        type = types.listOf types.str;
        default = [ ];
        example = [
          "/dev/kvm"
          "/dev/net/tun"
          "/dev/vfio/vfio"
        ];
        description = "List of device paths that QEMU processes are allowed to access.";
      };

      clearEmulationCapabilities = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to remove privileged Linux capabilities from QEMU processes after they start.";
      };
    };
  };

  config = {
    virtualisation = {
      libvirtd = {
        enable = mkDefault true;
        onBoot = mkDefault "ignore";
        onShutdown = mkDefault "shutdown";
        qemu.ovmf.enable = mkDefault true;
        qemu.runAsRoot = mkDefault false;
        qemu.verbatimConfig = ''
          clear_emulation_capabilities = ${boolToZeroOne cfg.libvirtd.clearEmulationCapabilities}
          cgroup_device_acl = [
            ${aclString}
          ]
        '';
        qemu.swtpm.enable = mkDefault true; # TPM 2.0
      };
      spiceUSBRedirection.enable = mkDefault true;
    };

    users.users."qemu-libvirtd" = {
      extraGroups = optionals (!cfg.libvirtd.qemu.runAsRoot) [
        "kvm"
        "input"
      ];
      isSystemUser = true;
    };

    programs.virt-manager.enable = mkDefault true;

    environment.systemPackages = [
      (pkgs.writeShellScriptBin "iommu-groups" (builtins.readFile ./iommu-groups.sh))
      pkgs.dnsmasq
      pkgs.qemu_full
      pkgs.virtio-win
    ];
  };
}
