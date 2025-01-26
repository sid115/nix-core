{ lib, pkgs, ... }:

let
  inherit (lib) mkDefault;
in
{
  programs.virt-manager.enable = mkDefault true;

  virtualisation.libvirtd = {
    enable = mkDefault true;
    qemu.ovmf.enable = mkDefault true;
    qemu.runAsRoot = mkDefault false;
    onBoot = mkDefault "ignore";
    onShutdown = mkDefault "shutdown";
  };

  environment.systemPackages = [
    (pkgs.writeShellScriptBin "iommu-groups" (builtins.readFile ./iommu-groups.sh))
    pkgs.dnsmasq
    pkgs.qemu_full
  ];
}
