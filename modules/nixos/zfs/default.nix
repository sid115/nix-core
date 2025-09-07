{ pkgs, lib, ... }:

# Set `networking.hostId` to:
# $ head -c 8 /etc/machine-id

# Mark datasets to snapshot:
# $ sudo zfs set com.sun:auto-snapshot:daily=true dpool/data/backup

# Generate SSH key for replication (empty passphrase):
# $ sudo -i ssh-keygen -t rsa -b 4096 -f /root/.ssh/zfs-replication

let
  inherit (lib) mkDefault mkForce;
in
{
  boot.supportedFilesystems = [ "zfs" ];
  boot.loader.systemd-boot.enable = mkForce false;
  boot.loader.grub.enable = mkForce true;
  boot.loader.grub.zfsSupport = mkForce true;

  services.zfs.trim = {
    enable = mkDefault true;
    interval = mkDefault "weekly";
  };

  services.zfs.srub = {
    enable = mkDefault true;
    interval = mkDefault "monthly";
  };

  services.zfs.autoSnapshot = {
    enable = mkDefault true;
    flags = mkDefault "-k -p --utc";
    frequent = mkDefault 0;
    hourly = mkDefault 24;
    daily = mkDefault 7;
    weekly = mkDefault 4;
    monthly = mkDefault 0;
  };

  services.zfs.autoReplication = {
    username = mkDefault "root";
    identityFilePath = mkDefault "/root/.ssh/zfs-replication";
    followDelete = mkDefault true;
  };

  environment.systemPackages = with pkgs; [ lz4 ];
}
